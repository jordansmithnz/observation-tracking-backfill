// Created by Jordan Smith

#if canImport(UIKit)
  import UIKit

  extension UICollectionViewCell {
    static var additionalExchangedObservationMethods: [ObservationTrackingBackfillMethod] {
      [
        .uiCellConfigurationState(#selector(updateConfiguration(using:))) {
          (cell: UICollectionViewCell, _: UICellConfigurationState) in
          cell.setNeedsUpdateConfiguration()
        }
      ]
    }
  }

  extension UITableViewCell {
    static var additionalExchangedObservationMethods: [ObservationTrackingBackfillMethod] {
      [
        .uiCellConfigurationState(#selector(updateConfiguration(using:))) {
          (cell: UITableViewCell, _: UICellConfigurationState) in
          cell.setNeedsUpdateConfiguration()
        }
      ]
    }
  }

  extension UITableViewHeaderFooterView {
    static var additionalExchangedObservationMethods: [ObservationTrackingBackfillMethod] {
      [
        .uiViewConfigurationState(#selector(updateConfiguration(using:))) {
          (view: UITableViewHeaderFooterView, _: UIViewConfigurationState) in
          view.setNeedsUpdateConfiguration()
        }
      ]
    }
  }
#endif
