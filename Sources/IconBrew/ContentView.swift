import SwiftUI
import UniformTypeIdentifiers
import AppKit

struct ContentView: View {
    @StateObject private var model = IconBrewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("IconBrew")
                .font(.system(size: 28, weight: .bold))

            Text("Drop an image to generate an AppIcon.icns")
                .font(.callout)
                .foregroundStyle(.secondary)

            DropArea(model: model)
                .frame(height: 220)

            Button {
                model.generate()
            } label: {
                Label("Generate .icns", systemImage: "wand.and.stars")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(model.inputURL == nil || model.isProcessing)
            .keyboardShortcut(.defaultAction)

            if model.resultIcns != nil {
                Button {
                    model.revealResult()
                } label: {
                    Label("Reveal in Finder", systemImage: "folder")
                        .frame(maxWidth: .infinity)
                }
            }

            if let status = model.status {
                Text(status)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }

            if model.isProcessing {
                ProgressView().controlSize(.small)
            }
        }
        .padding(24)
    }
}

struct DropArea: View {
    @ObservedObject var model: IconBrewModel
    @State private var isTargeted = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                .foregroundStyle(isTargeted ? Color.accentColor : Color.secondary.opacity(0.5))
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.secondary.opacity(isTargeted ? 0.15 : 0.05))
                )
            if let preview = model.inputPreview {
                Image(nsImage: preview)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .padding(16)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.down.on.square")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("Drag & drop an image here")
                        .font(.headline)
                    Text("PNG, JPEG — or click to choose")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { model.pickInput() }
        .onDrop(of: [UTType.fileURL], isTargeted: $isTargeted) { providers in
            guard let provider = providers.first else { return false }
            _ = provider.loadObject(ofClass: URL.self) { url, _ in
                if let url = url { DispatchQueue.main.async { model.setInput(url) } }
            }
            return true
        }
    }
}
