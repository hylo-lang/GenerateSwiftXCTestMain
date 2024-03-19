import XCTest
import DummyTestee

final class TestCase: XCTestCase {

  func test1() {
  }

  private func test() {
    XCTFail("This shouldn't run")
  }

  static func testStaticMethodsAreNotTests() {
    XCTFail("This shouldn't run")
  }

}

extension TestCase {

  func testExtensionMethodsCanBeTests() {}

}

struct StructsAreNotTestCases {

  func testStructMethodsAreNotTests() {
    XCTFail("This shouldn't run")
  }

  // Work around https://github.com/apple/swift-package-manager/issues/7411
  #if !os(Windows) && !os(Linux) || !BUILDING_WITH_SWIFT_PACKAGE_MANAGER
  class NestedStructClassesCanBeTestCases: XCTestCase {

    func testNestedClassMethodsCanBeTests() {}

  }
  #endif

}

enum EnumsAreNotTestCases {

  func testEnumMethodsAreNotTests() {
    XCTFail("This shouldn't run")
  }

  // Work around https://github.com/apple/swift-package-manager/issues/7411
  #if !os(Windows) && !os(Linux) || !BUILDING_WITH_SWIFT_PACKAGE_MANAGER
  class NestedEnumClassesCanBeTestCases: XCTestCase {

    func testNestedClassMethodsCanBeTests() {}

  }
  #endif

}

extension StructsAreNotTestCases {

  func testStructExtensionMethodsAreNotTests() {
    XCTFail("This shouldn't run")
  }

}

class NotAllClassesAreTestCases {

  func testNonXCTestCaseMethodsAreNotTests() {
    XCTFail("This shouldn't run")
  }

}
