<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/icon-dark.png" />
    <source media="(prefers-color-scheme: light)" srcset="docs/icon-light.png" />
    <img src="docs/icon-light.png" alt="IconBrew" width="160" height="160" />
  </picture>
</p>

<h1 align="center">IconBrew</h1>

<p align="center">Brew beautiful macOS icons from any image.</p>

IconBrew is a small, focused macOS utility that turns a single image into a ready to ship `AppIcon.icns` file. Drop in a PNG or JPEG, pick where to save, and IconBrew produces a properly sized, padded, multi resolution icon that you can drag straight into Xcode or use as your app's icon.

## What it does

IconBrew handles all the fiddly bits of preparing an icon for macOS so you don't have to:

- Normalizes your image into a square canvas while preserving its aspect ratio
- Adds a small safe margin so the artwork does not run into the edges and survives masking
- Generates every size macOS expects, from 16x16 up to 1024x1024, including the retina variants
- Packages everything into a single `AppIcon.icns` file ready for use
- Also leaves behind the intermediate `AppIcon.iconset` folder if you want the individual PNGs

The output is a clean, standards compliant icon set. macOS applies its own squircle mask, lighting, and dark mode adaptation when it displays the icon, so what shows up in the Dock and Finder matches every other native Mac app.

## Installation

1. Go to the Releases page of this repository and download the latest `IconBrew.zip`.
2. Open the archive and drag `IconBrew.app` into your Applications folder.
3. The first time you launch it, right click the app in Finder and choose Open, then confirm. This one time step is required by macOS for apps downloaded from the internet.

That is the entire setup. There are no dependencies to install and nothing to configure. IconBrew is a universal binary and runs natively on both Apple silicon and Intel Macs running macOS 12 or later.

## How to use it

1. Launch IconBrew.
2. Drag an image into the drop area in the middle of the window. You can also click the area to open a file picker. PNG and JPEG both work.
3. Click Generate .icns.
4. Choose the folder where you want the icon saved.
5. When IconBrew finishes, click Reveal in Finder to jump straight to the result.

Inside the folder you chose you will find:

- `AppIcon.icns`, the file you will most often want
- `AppIcon.iconset/`, the individual PNGs at every size in case you need them

To use the icon in an Xcode project, drag `AppIcon.icns` onto your target, or open your asset catalog and drop the individual PNGs into the AppIcon slots.

## Tips for the best result

- Start with the largest, cleanest version of your artwork you have. IconBrew can scale down beautifully but it cannot invent detail. A 1024x1024 source or larger is ideal.
- A square or near square source image gives the most predictable result. Very wide or very tall images end up with a lot of empty space around them after squaring.
- If your image already has a transparent background, that transparency is preserved in every generated size.
- If you want a colored background behind a logo, bake that color into the source image before bringing it into IconBrew. Do not pre apply rounded corners, shadows, or highlights, since macOS will add those for you and pre baking them causes double masking.

## Troubleshooting

- If the Generate button stays disabled, make sure you have actually loaded an image into the drop area.
- If the app refuses to open on first launch, right click it in Finder and choose Open. This bypasses Gatekeeper for unsigned downloads.
- If something goes wrong during generation, the status line at the bottom of the window will show what happened.

## License

See the LICENSE file in this repository.
