import Foundation

enum IconMakerError: LocalizedError {
    case toolFailed(String, Int32, String)
    case missingPixelDimensions

    var errorDescription: String? {
        switch self {
        case .toolFailed(let tool, let code, let msg):
            return "\(tool) failed (exit \(code)): \(msg)"
        case .missingPixelDimensions:
            return "Could not read image dimensions from sips"
        }
    }
}

/// Faithful Swift port of the bash script: normalizes the input to a padded
/// square with a 10% safe margin, generates all required iconset sizes via
/// `sips`, then bundles them into an `.icns` via `iconutil`.
enum IconMaker {

    /// Each entry: (pixel size, filename inside the .iconset).
    static let iconsetEntries: [(Int, String)] = [
        (16,   "icon_16x16.png"),
        (32,   "icon_16x16@2x.png"),
        (32,   "icon_32x32.png"),
        (64,   "icon_32x32@2x.png"),
        (128,  "icon_128x128.png"),
        (256,  "icon_128x128@2x.png"),
        (256,  "icon_256x256.png"),
        (512,  "icon_256x256@2x.png"),
        (512,  "icon_512x512.png"),
        (1024, "icon_512x512@2x.png"),
    ]

    /// Run the full pipeline. Returns the path to the generated `.icns`.
    static func makeIcns(source: URL, outputDir: URL) throws -> URL {
        let fm = FileManager.default
        try fm.createDirectory(at: outputDir, withIntermediateDirectories: true)

        let iconset = outputDir.appendingPathComponent("AppIcon.iconset")
        if fm.fileExists(atPath: iconset.path) {
            try fm.removeItem(at: iconset)
        }
        try fm.createDirectory(at: iconset, withIntermediateDirectories: true)

        let tmp = outputDir.appendingPathComponent("_tmp.png")
        defer { try? fm.removeItem(at: tmp) }

        // Step 1: convert to PNG into the temp file.
        try run("/usr/bin/sips", ["-s", "format", "png", source.path, "--out", tmp.path])

        // Read pixel dimensions.
        let (w, h) = try pixelDimensions(of: tmp)
        let size = max(w, h)

        // Pad to square.
        try run("/usr/bin/sips", ["--padToHeightWidth", "\(size)", "\(size)", tmp.path, "--out", tmp.path])

        // Scale to 90% for safe margin.
        let safe = size * 90 / 100
        try run("/usr/bin/sips", ["-z", "\(safe)", "\(safe)", tmp.path, "--out", tmp.path])

        // Re-pad to recenter on the original square.
        try run("/usr/bin/sips", ["--padToHeightWidth", "\(size)", "\(size)", tmp.path, "--out", tmp.path])

        // Step 2: generate every iconset size.
        for (px, name) in iconsetEntries {
            let dest = iconset.appendingPathComponent(name)
            try run("/usr/bin/sips", ["-z", "\(px)", "\(px)", tmp.path, "--out", dest.path])
        }

        // Step 3: pack into .icns.
        let icns = outputDir.appendingPathComponent("AppIcon.icns")
        try run("/usr/bin/iconutil", ["-c", "icns", iconset.path, "-o", icns.path])

        return icns
    }

    // MARK: - Helpers

    private static func pixelDimensions(of url: URL) throws -> (Int, Int) {
        let out = try captureStdout("/usr/bin/sips", ["-g", "pixelWidth", "-g", "pixelHeight", url.path])
        var width: Int?
        var height: Int?
        for line in out.split(separator: "\n") {
            let parts = line.trimmingCharacters(in: .whitespaces).split(separator: ":")
            if parts.count == 2 {
                let key = parts[0].trimmingCharacters(in: .whitespaces)
                let value = Int(parts[1].trimmingCharacters(in: .whitespaces))
                if key == "pixelWidth" { width = value }
                if key == "pixelHeight" { height = value }
            }
        }
        guard let w = width, let h = height else {
            throw IconMakerError.missingPixelDimensions
        }
        return (w, h)
    }

    @discardableResult
    private static func run(_ launchPath: String, _ args: [String]) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: launchPath)
        process.arguments = args

        let errPipe = Pipe()
        let outPipe = Pipe()
        process.standardError = errPipe
        process.standardOutput = outPipe

        try process.run()
        process.waitUntilExit()

        let outData = outPipe.fileHandleForReading.readDataToEndOfFile()
        let outStr = String(data: outData, encoding: .utf8) ?? ""

        if process.terminationStatus != 0 {
            let errStr = String(
                data: errPipe.fileHandleForReading.readDataToEndOfFile(),
                encoding: .utf8
            ) ?? ""
            let tool = (launchPath as NSString).lastPathComponent
            throw IconMakerError.toolFailed(tool, process.terminationStatus, errStr.isEmpty ? outStr : errStr)
        }
        return outStr
    }

    private static func captureStdout(_ launchPath: String, _ args: [String]) throws -> String {
        try run(launchPath, args)
    }
}
