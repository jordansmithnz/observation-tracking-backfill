// Created by Jordan Smith

#if canImport(UIKit)
import UIKit

extension UIViewController: ObservationTrackingBackfillCompatible {
  @objc func __backfill_init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) -> Self {
    Self.backfillObservationTracking()
    return self.__backfill_init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  // MARK: - ObservationTrackingBackfillCompatible

  static var exchangedObservationSelectors: [(original: Selector, updated: Selector)] {
    var selectors = [
      (#selector(viewWillLayoutSubviews), #selector(__backfill_viewWillLayoutSubviews)),
      (#selector(viewDidLayoutSubviews), #selector(__backfill_viewDidLayoutSubviews)),
      (#selector(updateViewConstraints), #selector(__backfill_updateViewConstraints)),
      (
        #selector(updateContentUnavailableConfiguration(using:)),
        #selector(__backfill_updateContentUnavailableConfiguration(using:))
      )
    ]

    if #available(iOS 26.0, tvOS 26.0, *) {
      selectors.append((#selector(updateProperties), #selector(__backfill_updateProperties)))
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

  @objc func __backfill_viewWillLayoutSubviews() {
    withObservationTracking {
      __backfill_viewWillLayoutSubviews()
    } onChange: { [weak self] in
      onMainIfNeeded { [weak self] in
        self?.view.setNeedsLayout()
      }
    }
  }

  @objc func __backfill_viewDidLayoutSubviews() {
    withObservationTracking {
      __backfill_viewDidLayoutSubviews()
    } onChange: { [weak self] in
      onMainIfNeeded { [weak self] in
        self?.view.setNeedsLayout()
      }
    }
  }

  @objc func __backfill_updateViewConstraints() {
    withObservationTracking {
      __backfill_updateViewConstraints()
    } onChange: { [weak self] in
      onMainIfNeeded { [weak self] in
        self?.view.setNeedsUpdateConstraints()
      }
    }
  }

  @objc func __backfill_updateContentUnavailableConfiguration(
    using state: UIContentUnavailableConfigurationState
  ) {
    withObservationTracking {
      __backfill_updateContentUnavailableConfiguration(using: state)
    } onChange: { [weak self] in
      onMainIfNeeded { [weak self] in
        self?.setNeedsUpdateContentUnavailableConfiguration()
      }
    }
  }
}
#endif
