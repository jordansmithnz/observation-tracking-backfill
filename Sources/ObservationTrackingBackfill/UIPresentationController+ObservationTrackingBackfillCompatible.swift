// Created by Jordan Smith

#if canImport(UIKit)
  import UIKit

  extension UIPresentationController: ObservationTrackingBackfillCompatible {
    // swift-format-ignore: AlwaysUseLowerCamelCase
    @objc func __backfill_init(
      presentedViewController: UIViewController,
      presenting presentingViewController: UIViewController?
    ) -> Self {
      Self.backfillObservationTracking()
      return self.__backfill_init(
        presentedViewController: presentedViewController,
        presenting: presentingViewController
      )
    }

    // MARK: - ObservationTrackingBackfillCompatible

    static var exchangedObservationMethods: [ObservationTrackingBackfillMethod] {
      [
        .void(#selector(containerViewWillLayoutSubviews)) {
          (presentationController: UIPresentationController) in
          presentationController.containerView?.setNeedsLayout()
        },
        .void(#selector(containerViewDidLayoutSubviews)) {
          (presentationController: UIPresentationController) in
          presentationController.containerView?.setNeedsLayout()
        },
      ]
    }
  }
#endif
