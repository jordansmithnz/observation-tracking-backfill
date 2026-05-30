// Created by Jordan Smith

#if canImport(UIKit)
  import UIKit

  extension UIViewController: ObservationTrackingBackfillCompatible {
    // swift-format-ignore: AlwaysUseLowerCamelCase
    @objc func __backfill_init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
      -> Self
    {
      Self.backfillObservationTracking()
      return self.__backfill_init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    // MARK: - ObservationTrackingBackfillCompatible

    static var exchangedObservationMethods: [ObservationTrackingBackfillMethod] {
      var methods: [ObservationTrackingBackfillMethod] = [
        .void(#selector(viewWillLayoutSubviews)) { (viewController: UIViewController) in
          viewController.view.setNeedsLayout()
        },
        .void(#selector(viewDidLayoutSubviews)) { (viewController: UIViewController) in
          viewController.view.setNeedsLayout()
        },
        .void(#selector(updateViewConstraints)) { (viewController: UIViewController) in
          viewController.view.setNeedsUpdateConstraints()
        },
        .uiContentUnavailableConfigurationState(
          #selector(updateContentUnavailableConfiguration(using:))
        ) {
          (viewController: UIViewController, _: UIContentUnavailableConfigurationState) in
          viewController.setNeedsUpdateContentUnavailableConfiguration()
        },
      ]

      if #available(iOS 26.0, tvOS 26.0, *) {
        methods.append(
          .void(#selector(updateProperties)) { (viewController: UIViewController) in
            viewController.setNeedsUpdateProperties()
          }
        )
      }

      return methods
    }
  }
#endif
