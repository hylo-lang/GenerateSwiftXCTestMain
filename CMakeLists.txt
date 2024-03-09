cmake_minimum_required(VERSION 3.26)

#
# Standard project boilerplate
#
project(GenerateSwiftXCTestMain
  VERSION 0.1.0
  DESCRIPTION "Cross-platform support for using XCTest in Swift projects"
  HOMEPAGE_URL "https://github.com/hylo-lang/SwiftCMakeXCTesting"
  LANGUAGES Swift
)
enable_testing()

list(PREPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/modules)

if (PROJECT_IS_TOP_LEVEL)
  include(cmake/TopLevelDefaults.cmake)
endif()

find_package(ArgumentParser REQUIRED)
find_package(SwiftSyntax REQUIRED)

add_executable(GenerateXCTestMain Sources/GenerateXCTestMain.swift)
target_link_libraries(GenerateXCTestMain
  ArgumentParser
  SwiftSyntax
  SwiftSyntaxBuilder
  SwiftOperators
  SwiftParser
  SwiftParserDiagnostics
)

# Needed where @main is used.
target_compile_options(GenerateXCTestMain PRIVATE -parse-as-library)

if(BUILD_TESTING)
  add_subdirectory(Tests)
endif()
