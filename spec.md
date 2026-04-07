# Macify — macOS Icon Generator

## Overview
Macify is a native macOS utility that transforms any input image (PNG, JPEG, etc.) into a polished macOS-style app icon set. It applies a gradient background, drop shadow, squircle masking, and generates all required icon sizes for macOS apps.

The goal is to provide a fast, visually clean, drag-and-drop experience for developers and designers to generate production-ready app icons.

---

## Core Features

### 1. Drag & Drop Input
- Users can drag an image into the app window
- Supported formats:
  - PNG
  - JPEG
  - WebP (optional)
  - SVG (optional future support)

---

### 2. Live Preview
- Show preview of:
  - Original image
  - Macified output
- Update preview when settings change

---

### 3. Macify Processing
- Apply:
  - Gradient background
  - Logo resizing and centering
  - Drop shadow
  - Squircle mask
  - Inner border stroke
- Based on ImageMagick pipeline

---

### 4. Icon Set Generation
Generate the following sizes:
- 1024x1024
- 512x512
- 256x256
- 128x128
- 64x64
- 32x32
- 16x16

Output structure:
AppIcon.appiconset/
app_icon_1024.png
app_icon_512.png
...

---

### 5. Export Options
- Save to selected directory
- One-click "Open Output Folder"
- Optional:
  - Export as `.icns`

---

## UI/UX Design

### Layout

+----------------------------------+
| Drag & Drop Area |
| |
| [ Preview Panel ] |
| |
| [ Macify Button ] |
| |
| [ Open Output Folder ] |
+----------------------------------+


---

## Optional Enhancements (V2)

- Toggle shadow ON/OFF
- Adjustable squircle radius
- Gradient presets
- Batch processing (multiple images)
- Save/export presets
- Dark mode optimized UI
- `.icns` direct export

---

## Tech Stack

### Frontend
- SwiftUI (native macOS UI)

### Backend / Processing
- ImageMagick (invoked via Process)
- Bash script (initial version)

---

## Architecture

### Flow
1. User drops image
2. Image preview loads
3. User clicks "Macify"
4. App executes:
   - macify.sh <input> <output>
5. Output files generated
6. User opens/export folder

---

## Dependencies

- ImageMagick (required for MVP)
- macOS 12+ (recommended)

---

## Risks & Considerations

- ImageMagick availability on user system
- Performance with large images
- Handling unsupported formats
- UI responsiveness during processing

---

## Future Direction

- Replace ImageMagick with native CoreImage pipeline
- Add cross-platform support (optional)
- Plugin system for custom icon styles
- Designer-focused presets

---

## Target Users

- Indie developers
- macOS/iOS app developers
- Designers
- Hackathon builders

---

## Positioning

Macify is a fast, no-bloat alternative to manual icon pipelines, giving you polished macOS icons in seconds.

---