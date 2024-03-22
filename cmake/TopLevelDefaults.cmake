# commands used to create an easy development environment when
# building this project directly (not as a dependency).

# Without this, generated Xcode projects aren't debuggable.
set(CMAKE_XCODE_GENERATE_SCHEME YES)

# Set up Hylo-standard dependency resolution.
include(FetchContent)
FetchContent_Declare(Hylo-CMakeModules
  GIT_REPOSITORY file:///Users/dave/src/Hylo-CMakeModules
  GIT_TAG        main)
FetchContent_MakeAvailable(Hylo-CMakeModules)
list(PREPEND CMAKE_MODULE_PATH ${hylo-cmakemodules_SOURCE_DIR})
