# GenerateSwiftXCTestMain

A tool that finds `XCTestCase`s and their `testXXX` methods and generates a `main.swift` to run
them.

## Why

On Apple platforms, test discovery is built into the OS and also works for tests written in
Objective-C.  On other platforms, it is built into the Swift Package Manager, but for other build
systems, you have to write (and maintain) the main function by hand. Or you could use a tool like
this one.

## How

[FindSwiftXCTest](https://github.com/hylo-lang/SwiftCMakeXCTesting) shows how this tool can be
integrated with CMake.

## Limitations

This tool parses the Swift test files using the official Swift parser, but doesn't know about
conditional compilation settings or how to expand Swift macros, and use of those features outside
the scope of test method bodies could produce unpredictable results.

## Build and Test

There are two methods:

1. **Swift Package Manager**: `swift test`
2. **CMake**: `

   ```sh
   mkdir path/to/build/directory
   cmake -DBUILD_TESTING=1 -GNinja -S . -B path/to/build/directory
   cmake --build path/to/build/directory
   ctest -V --test-dir path/to/build/directory
   ```
