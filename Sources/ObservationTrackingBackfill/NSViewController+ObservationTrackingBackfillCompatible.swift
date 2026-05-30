// Created by Jordan Smith

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
  import AppKit

  extension NSViewController: ObservationTrackingBackfillCompatible {
    // swift-format-ignore: AlwaysUseLowerCamelCase
    @objc func __backfill_init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?)
      -> Self
    {
      Self.backfillObservationTracking()
      return self.__backfill_init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    // MARK: - ObservationTrackingBackfillCompatible

    static var exchangedObservationMethods: [ObservationTrackingBackfillMethod] {
      [
        .void(#selector(updateViewConstraints)) { (viewController: NSViewController) in
          viewController.view.needsUpdateConstraints = true
        },
        .void(#selector(viewWillLayout)) { (viewController: NSViewController) in
          viewController.view.needsLayout = true
        },
        .void(#selector(viewDidLayout)) { (viewController: NSViewController) in
          viewController.view.needsLayout = true
        },
      ]
    }
  }
#endif
