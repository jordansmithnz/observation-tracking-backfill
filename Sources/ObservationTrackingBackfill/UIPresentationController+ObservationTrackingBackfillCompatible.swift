// Created by Jordan Smith

#if canImport(UIKit)
import UIKit

extension UIPresentationController: ObservationTrackingBackfillCompatible {
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

  static var exchangedObservationSelectors: [(original: Selector, updated: Selector)] {
    [
      (
        #selector(containerViewWillLayoutSubviews),
        #selector(__backfill_containerViewWillLayoutSubviews)
      ),
      (
        #selector(containerViewDidLayoutSubviews),
        #selector(__backfill_containerViewDidLayoutSubviews)
      )
    ]
  }

  @objc func __backfill_containerViewWillLayoutSubviews() {
    withObservationTracking {
      __backfill_containerViewWillLayoutSubviews()
    } onChange: { [weak self] in
      onMainIfNeeded { [weak self] in
        self?.containerView?.setNeedsLayout()
      }
    }
  }

  @objc func __backfill_containerViewDidLayoutSubviews() {
    withObservationTracking {
      __backfill_containerViewDidLayoutSubviews()
    } onChange: { [weak self] in
      onMainIfNeeded { [weak self] in
        self?.containerView?.setNeedsLayout()
      }
    }
  }
}
#endif
