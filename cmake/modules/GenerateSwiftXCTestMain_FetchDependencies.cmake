# Fetches dependencies for GenerateSwiftXCTestMain, almost unconditionally.  The only way to override
# this behavior is to use ``FETCHCONTENT_SOURCE_DIR_<uppercaseName>``.

include(FetchContent)

set(saved_FETCHCONTENT_TRY_FIND_PACKAGE_MODE ${FETCHCONTENT_TRY_FIND_PACKAGE_MODE})
set(FETCHCONTENT_TRY_FIND_PACKAGE_MODE NEVER)

FetchContent_Declare(SwiftCMakeXCTesting
  GIT_REPOSITORY https://github.com/hylo-lang/SwiftCMakeXCTesting.git
  GIT_TAG        main
  OVERRIDE_FIND_PACKAGE
)
FetchContent_Populate(SwiftCMakeXCTesting)
list(PREPEND CMAKE_MODULE_PATH ${swiftcmakexctesting_SOURCE_DIR}/cmake/modules)
include(FindSwiftXCTest)

FetchContent_Declare(SwiftSyntax
  GIT_REPOSITORY https://github.com/apple/swift-syntax.git
  GIT_TAG        main
  OVERRIDE_FIND_PACKAGE
)

FetchContent_Declare(ArgumentParser
  GIT_REPOSITORY https://github.com/apple/swift-argument-parser.git
  GIT_TAG        1.3.0
  OVERRIDE_FIND_PACKAGE
)

set(FETCHCONTENT_TRY_FIND_PACKAGE_MODE ${saved_FETCHCONTENT_TRY_FIND_PACKAGE_MODE})

# See https://github.com/apple/swift-syntax/pull/2454, which will hopefully make this clause
# unnecessary.  Without it CMake will fatal error when loading SwiftSyntax on some platforms.
if("${SWIFT_HOST_MODULE_TRIPLE}" STREQUAL "")
  execute_process(COMMAND ${CMAKE_Swift_COMPILER}
    -print-target-info OUTPUT_VARIABLE target-info)
  string(JSON SWIFT_HOST_MODULE_TRIPLE GET ${target-info} target moduleTriple)
endif()

set(saved_BUILD_EXAMPLES ${BUILD_EXAMPLES})
set(saved_BUILD_EXAMPLES ${BUILD_EXAMPLES})
set(BUILD_EXAMPLES NO)
set(BUILD_TESTING NO)

FetchContent_MakeAvailable(ArgumentParser SwiftSyntax)

set(BUILD_EXAMPLES ${saved_BUILD_EXAMPLES})
set(BUILD_EXAMPLES ${saved_BUILD_EXAMPLES})

# Suppress noisy warnings from dependencies.
target_compile_options(SwiftCompilerPluginMessageHandling PRIVATE -suppress-warnings)
target_compile_options(SwiftParser PRIVATE -suppress-warnings)
target_compile_options(SwiftParserDiagnostics PRIVATE -suppress-warnings)
target_compile_options(SwiftSyntaxMacroExpansion PRIVATE -suppress-warnings)
target_compile_options(SwiftOperators PRIVATE -suppress-warnings)
