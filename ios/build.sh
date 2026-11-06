#!/bin/bash
# Build the rcX iOS static libraries for arm64.
#
#   ./build.sh        a device:          ios/output/lib/{librccore.a,librcskia.a,libskia.a, Skia's shaper libs}
#   ./build.sh sim    the Simulator:     ios/output-sim/lib/...  (Apple silicon Macs)
#
# Headers: ios/output*/include/{rccore,rcskia}; Skia's under build*/_deps/skia-src.
#
# These are what the iOS app under apps/iosViewer/ links against.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

SDK=iphoneos
BUILD_DIR="build"
OUTPUT_DIR="output"
if [ "${1:-}" = "sim" ]; then
    SDK=iphonesimulator
    BUILD_DIR="build-sim"
    OUTPUT_DIR="output-sim"
fi

# Allow override but default to the bundled toolchain file.
TOOLCHAIN_FILE="${TOOLCHAIN_FILE:-$SCRIPT_DIR/ios.toolchain.cmake}"
# The engine sources: kobento-libs, a sibling checkout of kobento-ios.
KOBENTO_LIBS_DIR="${KOBENTO_LIBS_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)/kobento-libs}"

echo "=== Configuring iOS build ($SDK) ==="
cmake -B "$BUILD_DIR" -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN_FILE" -DKOBENTO_LIBS_DIR="$KOBENTO_LIBS_DIR" -DRC_IOS_SDK="$SDK"

echo "=== Building ==="
cmake --build "$BUILD_DIR" -j"$(sysctl -n hw.ncpu)"

echo "=== Collecting output ==="
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/lib" "$OUTPUT_DIR/include"

cp "$BUILD_DIR/rccore/librccore.a" "$OUTPUT_DIR/lib/"
cp "$BUILD_DIR/rcskia/librcskia.a" "$OUTPUT_DIR/lib/"

# libskia.a comes from the FetchContent extract under build/_deps/skia-src/out/..., with what
# rcskia's text shaping needs from the same pack (rcskia/CMakeLists.txt links the same five).
SKIA_LIB=$(find "$BUILD_DIR/_deps/skia-src/out" -name "libskia.a" -maxdepth 2 | head -1)
if [ -n "${SKIA_LIB:-}" ]; then
    SKIA_OUT=$(dirname "$SKIA_LIB")
    for lib in skia skshaper skunicode_icu skunicode_core harfbuzz icu; do
        cp "$SKIA_OUT/lib$lib.a" "$OUTPUT_DIR/lib/"
    done
    echo "Copied Skia: $SKIA_OUT"
else
    echo "warning: libskia.a not found under $BUILD_DIR/_deps/skia-src/out" >&2
fi

cp -R "$KOBENTO_LIBS_DIR/lib/rccore/include/rccore" "$OUTPUT_DIR/include/rccore"
cp -R "$KOBENTO_LIBS_DIR/lib/rcskia/include/rcskia" "$OUTPUT_DIR/include/rcskia"

echo ""
echo "=== Done ==="
for lib in "$OUTPUT_DIR"/lib/*.a; do
    echo "  $(basename "$lib") ($(du -h "$lib" | cut -f1 | xargs))"
    lipo -info "$lib" 2>/dev/null || true
done
echo "Headers: $OUTPUT_DIR/include/rccore/, $OUTPUT_DIR/include/rcskia/"
