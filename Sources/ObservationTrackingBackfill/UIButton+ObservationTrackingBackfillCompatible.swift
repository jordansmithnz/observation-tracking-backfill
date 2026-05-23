// Created by Jordan Smith

#if canImport(UIKit)
import UIKit

extension UIButton {
  static var additionalExchangedObservationSelectors: [(original: Selector, updated: Selector)] {
    [
      (#selector(updateConfiguration), #selector(__backfill_updateConfiguration))
    ]
  }

  @objc func __backfill_updateConfiguration() {
    withObservationTracking {
      __backfill_updateConfiguration()
    } onChange: { [weak self] in
      onMainIfNeeded { [weak self] in
        self?.setNeedsUpdateConfiguration()
      }
    }
  }
}
#endif
