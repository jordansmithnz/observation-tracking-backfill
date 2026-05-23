// Created by Jordan Smith

import Foundation

@MainActor
protocol ObservationTrackingBackfillCompatible: AnyObject {
  static var exchangedObservationSelectors: [(original: Selector, updated: Selector)] { get }
}

extension NSObject {
  class func backfillObservationTracking() {
    onMainIfNeeded {
      guard !ObservationTrackingBackfillRegistry.shared.includes(self) else { return }
      ObservationTrackingBackfillRegistry.shared.insert(self)
      guard let compatibleType = self as? ObservationTrackingBackfillCompatible.Type else { return }
      let selectors = compatibleType.exchangedObservationSelectors
      for (original, updated) in selectors {
        guard implementsSelector(self, original) else { continue }
        performLocalizedMethodExchange(
          self,
          original,
          updated
        )
      }
    }
  }
}
