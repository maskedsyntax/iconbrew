import SwiftUI
import AppKit
import UniformTypeIdentifiers

@MainActor
final class IconBrewModel: ObservableObject {
    @Published var inputURL: URL?
    @Published var inputPreview: NSImage?
    @Published var resultIcns: URL?
    @Published var status: String?
    @Published var isProcessing = false

    func setInput(_ url: URL) {
        inputURL = url
        inputPreview = NSImage(contentsOf: url)
        resultIcns = nil
        status = "Loaded: \(url.lastPathComponent)"
    }

    func pickInput() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.png, .jpeg, .image]
        panel.allowsMultipleSelection = false
        if panel.runModal() == .OK, let url = panel.url {
            setInput(url)
        }
    }

    func generate() {
        guard let input = inputURL else { return }

        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.prompt = "Choose Output Folder"
        guard panel.runModal() == .OK, let outDir = panel.url else { return }

        isProcessing = true
        status = "Generating .icns…"

        // The model is @MainActor, so an unstructured Task inherits MainActor.
        // The blocking IconMaker work runs on a detached child Task; results
        // come back to MainActor automatically when we await its value.
        Task {
            do {
                let icns = try await Task.detached {
                    try IconMaker.makeIcns(source: input, outputDir: outDir)
                }.value
                self.resultIcns = icns
                self.isProcessing = false
                self.status = "Done: \(icns.path)"
            } catch {
                self.isProcessing = false
                self.status = "Error: \(error.localizedDescription)"
            }
        }
    }

    func revealResult() {
        guard let resultIcns else { return }
        NSWorkspace.shared.activateFileViewerSelecting([resultIcns])
    }
}
