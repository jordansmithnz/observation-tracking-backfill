// Created by Jordan Smith

import Foundation
import ObjectiveC
@testable import ObservationTrackingBackfill
import XCTest

final class ObservationTrackingBackfillRuntimeTests: XCTestCase {
  func testImplementsSelectorOnlyReturnsTrueForLocalOverrides() {
    XCTAssertFalse(implementsSelector(InheritedSelectorProbe.self, #selector(SelectorProbe.foo)))
    XCTAssertTrue(implementsSelector(OverriddenSelectorProbe.self, #selector(SelectorProbe.foo)))
  }

  func testLocalizedMethodExchangeOnlyAffectsRequestedSubclass() {
    let originalSelector = #selector(ExchangeProbe.foo)
    let updatedSelector = #selector(ExchangeProbe.__backfill_value)
    let inheritedImplementation = implementation(
      of: originalSelector,
      on: InheritedExchangeProbe.self
    )
    let overriddenImplementation = implementation(
      of: originalSelector,
      on: OverriddenExchangeProbe.self
    )
    let updatedImplementation = implementation(
      of: updatedSelector,
      on: OverriddenExchangeProbe.self
    )

    performLocalizedMethodExchange(
      OverriddenExchangeProbe.self,
      originalSelector,
      updatedSelector
    )

    XCTAssertEqual(implementation(of: originalSelector, on: InheritedExchangeProbe.self), inheritedImplementation)
    XCTAssertEqual(implementation(of: originalSelector, on: OverriddenExchangeProbe.self), updatedImplementation)
    XCTAssertEqual(implementation(of: updatedSelector, on: OverriddenExchangeProbe.self), overriddenImplementation)
  }
}

private func implementation(
  of selector: Selector,
  on type: AnyClass
) -> IMP? {
  class_getInstanceMethod(type, selector).map(method_getImplementation)
}

private class SelectorProbe: NSObject {
  @objc dynamic func foo() -> String {
    "base"
  }
}

private final class InheritedSelectorProbe: SelectorProbe {}

private final class OverriddenSelectorProbe: SelectorProbe {
  override func foo() -> String {
    "override"
  }
}

private class ExchangeProbe: NSObject {
  @objc dynamic func foo() -> String {
    "base"
  }

  @objc dynamic func __backfill_value() -> String {
    "backfill"
  }
}

private final class InheritedExchangeProbe: ExchangeProbe {}

private final class OverriddenExchangeProbe: ExchangeProbe {
  override func foo() -> String {
    "override"
  }
}
