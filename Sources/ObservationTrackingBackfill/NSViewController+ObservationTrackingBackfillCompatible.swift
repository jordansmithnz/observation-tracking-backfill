// Created by Jordan Smith

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

extension NSViewController: ObservationTrackingBackfillCompatible {
  @objc func __backfill_init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) -> Self {
    Self.backfillObservationTracking()
    return self.__backfill_init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  // MARK: - ObservationTrackingBackfillCompatible

  static var exchangedObservationSelectors: [(original: Selector, updated: Selector)] {
    [
      (#selector(updateViewConstraints), #selector(__backfill_updateViewConstraints)),
      (#selector(viewWillLayout), #selector(__backfill_viewWillLayout)),
      (#selector(viewDidLayout), #selector(__backfill_viewDidLayout))
    ]
  }

  @objc func __backfill_updateViewConstraints() {
    withObservationTracking {
      __backfill_updateViewConstraints()
    } onChange: { [weak self] in
      onMainIfNeeded { [weak self] in
        self?.view.needsUpdateConstraints = true
      }
    }
  }

  @objc func __backfill_viewWillLayout() {
    withObservationTracking {
      __backfill_viewWillLayout()
    } onChange: { [weak self] in
      onMainIfNeeded { [weak self] in
        self?.view.needsLayout = true
      }
    }
  }

  @objc func __backfill_viewDidLayout() {
    withObservationTracking {
      __backfill_viewDidLayout()
    } onChange: { [weak self] in
      onMainIfNeeded { [weak self] in
        self?.view.needsLayout = true
      }
    }
  }
}
#endif
