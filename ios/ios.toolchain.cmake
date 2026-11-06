set(CMAKE_SYSTEM_NAME iOS)
set(CMAKE_OSX_ARCHITECTURES arm64)
set(CMAKE_OSX_DEPLOYMENT_TARGET 17.0)   # the apps' target; the engine needs 16.3+ (std::to_chars for floats)
# iphoneos (a device, the default) or iphonesimulator (-DRC_IOS_SDK=iphonesimulator; build.sh sim).
if(NOT RC_IOS_SDK)
  set(RC_IOS_SDK iphoneos)
endif()
set(CMAKE_OSX_SYSROOT ${RC_IOS_SDK})
