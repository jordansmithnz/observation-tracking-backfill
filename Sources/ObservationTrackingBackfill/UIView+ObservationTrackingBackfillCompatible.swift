// Created by Jordan Smith

#if canImport(UIKit)
import UIKit

extension UIView: ObservationTrackingBackfillCompatible {
  @objc func __backfill_init(frame: CGRect) -> Self {
    Self.backfillObservationTracking()
    return __backfill_init(frame: frame)
  }

  // MARK: - ObservationTrackingBackfillCompatible

  static var exchangedObservationSelectors: [(original: Selector, updated: Selector)] {
    var selectors = [
      (#selector(layoutSubviews), #selector(__backfill_layoutSubviews)),
      (#selector(updateConstraints), #selector(__backfill_updateConstraints)),
      (#selector(draw(_:)), #selector(__backfill_draw(_:)))
    ]

    if #available(iOS 26.0, tvOS 26.0, *) {
      selectors.append((#selector(updateProperties), #selector(__backfill_updateProperties)))
    }

    if let buttonType = self as? UIButton.Type {
      selectors += buttonType.additionalExchangedObservationSelectors
    }

    if let collectionViewCellType = self as? UICollectionViewCell.Type {
      selectors += collectionViewCellType.additionalExchangedObservationSelectors
    }

    if let tableViewCellType = self as? UITableViewCell.Type {
      selectors += tableViewCellType.additionalExchangedObservationSelectors
    }

    if let headerFooterViewType = self as? UITableViewHeaderFooterView.Type {
      selectors += headerFooterViewType.additionalExchangedObservationSelectors
    }

    return selectors
  }

  @available(iOS 26.0, tvOS 26.0, *)
  @objc func __backfill_updateProperties() {
    withObservationTracking {
      __backfill_updateProperties()
    } onChange: { [weak self] in
      onMainIfNeeded { [weak self] in
        self?.setNeedsUpdateProperties()
      }
    }
  }

  @objc func __backfill_layoutSubviews() {
    withObservationTracking {
      __backfill_layoutSubviews()
    } onChange: { [weak self] in
      onMainIfNeeded { [weak self] in
        self?.setNeedsLayout()
      }
    }
  }

  @objc func __backfill_updateConstraints() {
    withObservationTracking {
      __backfill_updateConstraints()
    } onChange: { [weak self] in
      onMainIfNeeded { [weak self] in
        self?.setNeedsUpdateConstraints()
      }
    }
  }

  @objc func __backfill_draw(_ rect: CGRect) {
    withObservationTracking {
      __backfill_draw(rect)
    } onChange: { [weak self] in
      onMainIfNeeded { [weak self] in
        self?.setNeedsDisplay(rect)
      }
    }
  }
}
#endif
