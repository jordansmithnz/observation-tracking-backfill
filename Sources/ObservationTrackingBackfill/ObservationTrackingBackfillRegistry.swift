// Created by Jordan Smith

@MainActor
class ObservationTrackingBackfillRegistry {
  static let shared = ObservationTrackingBackfillRegistry()
  private var backfilledTypes = Set<ObjectIdentifier>()

  func includes(_ type: AnyClass) -> Bool {
    backfilledTypes.contains(ObjectIdentifier(type))
  }

  func insert(_ type: AnyClass) {
    backfilledTypes.insert(ObjectIdentifier(type))
  }
}
