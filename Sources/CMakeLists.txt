find_package(ArgumentParser REQUIRED)
find_package(SwiftSyntax REQUIRED)

add_executable(GenerateSwiftXCTestMain GenerateSwiftXCTestMain.swift)

target_link_libraries(GenerateSwiftXCTestMain
  ArgumentParser
  SwiftSyntax
  SwiftSyntaxBuilder
  SwiftOperators
  SwiftParser
  SwiftParserDiagnostics
)

# Needed where @main is used.
target_compile_options(GenerateSwiftXCTestMain PRIVATE -parse-as-library)
