// Created by Jordan Smith

#if canImport(UIKit)
  import UIKit

  extension UIButton {
    static var additionalExchangedObservationMethods: [ObservationTrackingBackfillMethod] {
      [
        .void(#selector(updateConfiguration)) { (button: UIButton) in
          button.setNeedsUpdateConfiguration()
        }
      ]
    }
  }
#endif
