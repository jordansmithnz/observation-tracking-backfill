// Created by Jordan Smith

#if canImport(UIKit)
import UIKit

extension UICollectionViewCell {
  static var additionalExchangedObservationSelectors: [(original: Selector, updated: Selector)] {
    [
      (
        #selector(updateConfiguration(using:)),
        #selector(__backfill_updateConfiguration(using:))
      )
    ]
  }

  @objc func __backfill_updateConfiguration(using state: UICellConfigurationState) {
    withObservationTracking {
      __backfill_updateConfiguration(using: state)
    } onChange: { [weak self] in
      onMainIfNeeded { [weak self] in
        self?.setNeedsUpdateConfiguration()
      }
    }
  }
}

extension UITableViewCell {
  static var additionalExchangedObservationSelectors: [(original: Selector, updated: Selector)] {
    [
      (
        #selector(updateConfiguration(using:)),
        #selector(__backfill_updateConfiguration(using:))
      )
    ]
  }

  @objc func __backfill_updateConfiguration(using state: UICellConfigurationState) {
    withObservationTracking {
      __backfill_updateConfiguration(using: state)
    } onChange: { [weak self] in
      onMainIfNeeded { [weak self] in
        self?.setNeedsUpdateConfiguration()
      }
    }
  }
}

extension UITableViewHeaderFooterView {
  static var additionalExchangedObservationSelectors: [(original: Selector, updated: Selector)] {
    [
      (
        #selector(updateConfiguration(using:)),
        #selector(__backfill_updateConfiguration(using:))
      )
    ]
  }

  @objc func __backfill_updateConfiguration(using state: UIViewConfigurationState) {
    withObservationTracking {
      __backfill_updateConfiguration(using: state)
    } onChange: { [weak self] in
      onMainIfNeeded { [weak self] in
        self?.setNeedsUpdateConfiguration()
      }
    }
  }
}
#endif
