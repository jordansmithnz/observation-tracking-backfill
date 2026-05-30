// Created by Jordan Smith

import Foundation
import ObjectiveC
import Observation
import XCTest

@testable import ObservationTrackingBackfill

final class ObservationTrackingBackfillRuntimeTests: XCTestCase {
  func testImplementsSelectorOnlyReturnsTrueForLocalOverrides() {
    XCTAssertFalse(implementsSelector(InheritedSelectorProbe.self, #selector(SelectorProbe.foo)))
    XCTAssertTrue(implementsSelector(OverriddenSelectorProbe.self, #selector(SelectorProbe.foo)))
  }

  func testObservationTrackingBackfillMethodPreservesSuperCallChains() {
    ObservationProbeLog.shared.reset()
    let method = ObservationTrackingBackfillMethod.void(#selector(RootObservationProbe.foo)) {
      (_: RootObservationProbe) in
    }

    method.install(LeafObservationProbe.self)
    method.install(MiddleObservationProbe.self)

    LeafObservationProbe().foo()

    XCTAssertEqual(ObservationProbeLog.shared.calls, ["leaf", "middle", "root"])
  }

  func testObservationTrackingBackfillMethodTracksChangesThroughMultipleOverrides() {
    ObservationInvalidationLog.shared.reset()
    let model = ObservationTrackingModel()
    let probe = LeafTrackingProbe(model: model)
    let method = ObservationTrackingBackfillMethod.void(#selector(RootTrackingProbe.foo)) {
      (probe: RootTrackingProbe) in
      ObservationInvalidationLog.shared.append(ObjectIdentifier(probe))
    }

    method.install(LeafTrackingProbe.self)
    method.install(MiddleTrackingProbe.self)

    probe.foo()
    XCTAssertEqual(ObservationInvalidationLog.shared.invalidations, [])

    model.value = 1

    XCTAssertEqual(
      ObservationInvalidationLog.shared.invalidations,
      [ObjectIdentifier(probe)]
    )
  }
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

private final class ObservationProbeLog: @unchecked Sendable {
  static let shared = ObservationProbeLog()

  private let lock = NSLock()
  private var storedCalls: [String] = []

  var calls: [String] {
    lock.lock()
    defer { lock.unlock() }

    return storedCalls
  }

  func append(_ call: String) {
    lock.lock()
    defer { lock.unlock() }

    storedCalls.append(call)
  }

  func reset() {
    lock.lock()
    defer { lock.unlock() }

    storedCalls = []
  }
}

private class RootObservationProbe: NSObject {
  @objc dynamic func foo() {
    ObservationProbeLog.shared.append("root")
  }
}

private class MiddleObservationProbe: RootObservationProbe {
  override func foo() {
    ObservationProbeLog.shared.append("middle")
    super.foo()
  }
}

private final class LeafObservationProbe: MiddleObservationProbe {
  override func foo() {
    ObservationProbeLog.shared.append("leaf")
    super.foo()
  }
}

@Observable
private final class ObservationTrackingModel {
  var value = 0
}

private final class ObservationInvalidationLog: @unchecked Sendable {
  static let shared = ObservationInvalidationLog()

  private let lock = NSLock()
  private var storedInvalidations: [ObjectIdentifier] = []

  var invalidations: [ObjectIdentifier] {
    lock.lock()
    defer { lock.unlock() }

    return storedInvalidations
  }

  func append(_ invalidation: ObjectIdentifier) {
    lock.lock()
    defer { lock.unlock() }

    storedInvalidations.append(invalidation)
  }

  func reset() {
    lock.lock()
    defer { lock.unlock() }

    storedInvalidations = []
  }
}

private class RootTrackingProbe: NSObject {
  let model: ObservationTrackingModel

  init(model: ObservationTrackingModel) {
    self.model = model
  }

  @objc dynamic func foo() {
    _ = model.value
  }
}

private class MiddleTrackingProbe: RootTrackingProbe {
  override func foo() {
    super.foo()
  }
}

private final class LeafTrackingProbe: MiddleTrackingProbe {
  override func foo() {
    super.foo()
  }
}
