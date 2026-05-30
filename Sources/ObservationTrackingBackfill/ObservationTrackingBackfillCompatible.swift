// Created by Jordan Smith

import Foundation

@MainActor
protocol ObservationTrackingBackfillCompatible: AnyObject {
  static var exchangedObservationMethods: [ObservationTrackingBackfillMethod] { get }
}

extension NSObject {
  class func backfillObservationTracking() {
    onMainIfNeeded {
      guard !ObservationTrackingBackfillRegistry.shared.includes(self) else { return }
      ObservationTrackingBackfillRegistry.shared.insert(self)
      guard let compatibleType = self as? ObservationTrackingBackfillCompatible.Type else { return }
      let methods = compatibleType.exchangedObservationMethods
      for method in methods {
        guard implementsSelector(self, method.selector) else { continue }
        method.install(self)
      }
    }
  }
}
