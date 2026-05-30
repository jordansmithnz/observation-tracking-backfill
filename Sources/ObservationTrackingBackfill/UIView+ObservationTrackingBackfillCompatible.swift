// Created by Jordan Smith

#if canImport(UIKit)
  import UIKit

  extension UIView: ObservationTrackingBackfillCompatible {
    // swift-format-ignore: AlwaysUseLowerCamelCase
    @objc func __backfill_init(frame: CGRect) -> Self {
      Self.backfillObservationTracking()
      return __backfill_init(frame: frame)
    }

    // MARK: - ObservationTrackingBackfillCompatible

    static var exchangedObservationMethods: [ObservationTrackingBackfillMethod] {
      var methods: [ObservationTrackingBackfillMethod] = [
        .void(#selector(layoutSubviews)) { (view: UIView) in
          view.setNeedsLayout()
        },
        .void(#selector(updateConstraints)) { (view: UIView) in
          view.setNeedsUpdateConstraints()
        },
        .cgRect(#selector(draw(_:))) { (view: UIView, rect: CGRect) in
          view.setNeedsDisplay(rect)
        },
      ]

      if #available(iOS 26.0, tvOS 26.0, *) {
        methods.append(
          .void(#selector(updateProperties)) { (view: UIView) in
            view.setNeedsUpdateProperties()
          }
        )
      }

      if let buttonType = self as? UIButton.Type {
        methods += buttonType.additionalExchangedObservationMethods
      }

      if let collectionViewCellType = self as? UICollectionViewCell.Type {
        methods += collectionViewCellType.additionalExchangedObservationMethods
      }

      if let tableViewCellType = self as? UITableViewCell.Type {
        methods += tableViewCellType.additionalExchangedObservationMethods
      }

      if let headerFooterViewType = self as? UITableViewHeaderFooterView.Type {
        methods += headerFooterViewType.additionalExchangedObservationMethods
      }

      return methods
    }
  }
#endif
