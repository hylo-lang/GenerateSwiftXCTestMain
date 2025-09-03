#if canImport(Darwin)
  @preconcurrency import Darwin
#elseif canImport(Glibc)
  @preconcurrency import Glibc // disable concurrency safety checks for stdout/stderr flushing
#elseif canImport(CRT)
  @preconcurrency import CRT
#endif

// Must be after the Glibc import, because the first occurency of a (transitive) import determines whether
// something is a @preconcurrency import.
import XCTest

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

private extension TestCase {

  static var allTests: AllTests<TestCase> {
    return [
      ("test1", test1),
      ("testExtensionMethodsCanBeTests", testExtensionMethodsCanBeTests),
    ]
  }

}

private extension StructsAreNotTestCases.NestedStructClassesCanBeTestCases {

  static var allTests: AllTests<StructsAreNotTestCases.NestedStructClassesCanBeTestCases> {
    return [
      ("testNestedClassMethodsCanBeTests", testNestedClassMethodsCanBeTests),
    ]
  }

}

private extension StructsAreNotTestCases {

  static var allTests: AllTests<StructsAreNotTestCases> {
    return [
      ("testStructExtensionMethodsAreNotTests", testStructExtensionMethodsAreNotTests),
    ]
  }

}

private extension EnumsAreNotTestCases.NestedEnumClassesCanBeTestCases {

  static var allTests: AllTests<EnumsAreNotTestCases.NestedEnumClassesCanBeTestCases> {
    return [
      ("testNestedClassMethodsCanBeTests", testNestedClassMethodsCanBeTests),
    ]
  }

}

private extension NotAllClassesAreTestCases {

  static var allTests: AllTests<NotAllClassesAreTestCases> {
    return [
      ("testNonXCTestCaseMethodsAreNotTests", testNonXCTestCaseMethodsAreNotTests),
    ]
  }

}

/// Feeds `allTestCases` to `XCTMain` if the latter is available.
func runAllTestCases() {
  /// The full complement of test cases and their individual tests
  let allTestCases: [XCTestCaseEntry] = [
    TestCase.allTests.eraseTestTypes(),
  StructsAreNotTestCases.NestedStructClassesCanBeTestCases.allTests.eraseTestTypes(),
  StructsAreNotTestCases.allTests.eraseTestTypes(),
  EnumsAreNotTestCases.NestedEnumClassesCanBeTestCases.allTests.eraseTestTypes(),
  NotAllClassesAreTestCases.allTests.eraseTestTypes()
  ]
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