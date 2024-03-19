import ArgumentParser
import Foundation

/// Mapping from (presumed) XCTest type names to a list of test method
/// names.
typealias TestCatalog = [String: [String]]

/// A command-line tool that generates XCTest cases for a list of annotated ".hylo" files as part of
/// our build process.
@main
struct GenerateSwiftXCTestMain: ParsableCommand {

  @Option(
    name: [.customShort("o")],
    help: ArgumentHelp("Write output to <file>.", valueName: "output-swift-file"),
    transform: URL.init(fileURLWithPath:))
  var main: URL

  @Argument(
    help: "Paths of files to be scraped for invocable XCTests.",
    transform: URL.init(fileURLWithPath:))
  var sourcesToScrape: [URL]

  /// Returns a mapping from (presumed) XCTest type names in `sourcesToScrape` to an array of names
  /// of test methods.
  ///
  /// Scraping is primitive.  Any nullary non-static method in a class definition or in an extension
  /// of any type whose name begins with `test` will be included.  Use of constructs that complicate
  /// the syntax, including conditional compilation and Swift macros, could cause problems.  In
  /// particular, do not conditionally compile-out whole tests, or the generated code will end up
  /// referencing tests that don't "exist."  Instead, conditionally compile-out the bodies of tests.
  func discoveredTests() throws -> TestCatalog {
    try sourcesToScrape.map(discoveredTests(in:)).reduce(into: TestCatalog()) {
      $0.merge($1, uniquingKeysWith: +)
    }
  }

  /// Returns a mapping from (presumed) XCTest type names in `f` to an array of names of test
  /// methods.
  ///
  /// - See also: `discoveredTests()` for more information.
  func discoveredTests(in f: URL) throws -> TestCatalog {
    return [:]
  }

  /// Returns the text of an extension to the type named `testCaseName` that adds a static
  /// `allTests` array of test (name, function) pairs.
  func allTestsExtension(testCaseName: String, testNames: [String]) -> String {
    """
    private extension \(testCaseName) {

      static var allTests: AllTests<\(testCaseName)> {
        return [
    \(testNames.map { "      (\(String(reflecting: $0)), \($0))," }.joined(separator: "\n"))
        ]
      }

    }
    """
  }

  func run() throws {

    let tests = try discoveredTests()

    let output =
      """
      import XCTest
      #if canImport(Darwin)
        import Darwin
      #elseif canImport(Glibc)
        import Glibc
      #elseif canImport(CRT)
        import CRT
      #endif

      // Type names not exported by the proprietary version of XCTest .
      #if os(macOS) && !canImport(SwiftXCTest)
        private typealias XCTestCaseClosure = (XCTestCase) throws -> Void
        private typealias XCTestCaseEntry
          = (testCaseClass: XCTestCase.Type, allTests: [(String, XCTestCaseClosure)])
      #endif

      /// The type of `T`'s generated static `allTests` property.
      private typealias AllTests<T> = [(String, (T) -> () throws -> Void)]

      private extension Array {

        /// Transforms `self` into an `XCTestCaseEntry` by erasing `T` from the type and representing
        /// it as a string, or returns an empty result if `T` is-not-a `XCTestCase`.
        func eraseTestTypes<T>() -> XCTestCaseEntry where Self == AllTests<T> {
          guard let t = T.self as? XCTestCase.Type else {
            // Skip any methods scraped from non-XCTestCase types.
            return (testCaseClass: XCTestCase.self, allTests: [])
          }

          func xcTestCaseClosure(_ f: @escaping (T) -> () throws -> Void) -> XCTestCaseClosure {
            { (x: XCTestCase) throws -> Void in try f(x as! T)() }
          }

          let allTests = self.map { name_f in (name_f.0, xcTestCaseClosure(name_f.1)) }
          return (testCaseClass: t, allTests: allTests)
        }

      }

      \(tests.map(allTestsExtension).joined(separator: "\n\n"))

      /// The full complement of test cases and their individual tests
      private let allTestCases: [XCTestCaseEntry] = [
        \(tests.keys.map {"\($0).allTests.eraseTestTypes()"}.joined(separator: ",\n  "))
      ]

      /// Feeds `allTestCases` to `XCTMain` if the latter is available.
      func runAllTestCases() {
        #if !os(Windows)
          // ignore SIGPIPE which is sent when writing to closed file descriptors.
          _ = signal(SIGPIPE, SIG_IGN)
        #endif

        atexit({
          fflush(stdout)
          fflush(stderr)
        })
        #if !os(macOS) || canImport(SwiftXCTest)
          XCTMain(allTestCases)
        #endif
      }
      runAllTestCases()
      """

    try output.write(to: main, atomically: true, encoding: .utf8)
  }

}
