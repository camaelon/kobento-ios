# kobento-ios

The Kobento iOS player for [RemoteCompose](https://github.com/androidx/androidx/tree/androidx-main/compose/remote)
documents.

```
kobento-ios/
├── ios/         CMake setup that builds the engine (rccore), the Skia bridge (rcskia) and Skia
│                for iOS arm64, into static libs under ios/output/
├── iosNative/   rcnative — a paint backend on Core Graphics / Core Text, no Skia (most of a
│                Skia build's size); it also builds on macOS, where kobento-tools' rc2image-native uses it
└── iosViewer/   the SwiftUI iOS / iPadOS app, MTKView + Skia-Ganesh-Metal. See iosViewer/README.md.
```

## Build

The engine sources come from [kobento-libs](https://github.com/camaelon/kobento-libs), a sibling
checkout (or `KOBENTO_LIBS_DIR`):

```sh
git clone https://github.com/camaelon/kobento-libs ../kobento-libs
(cd ios && ./build.sh)              # static libs → ios/output/
(cd iosNative && ./build.sh)        # librcnative.a
(cd iosViewer && ./build.sh)        # xcodegen + the app
```

Open `iosViewer/iosViewer.xcodeproj` in Xcode, pick a device or an arm64 Simulator, set a signing
team, and ⌘R. kobento-libs' BUILDING.md has the full walk-through.

This repository is not endorsed or supported by Google.
