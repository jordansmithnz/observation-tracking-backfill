// Created by Jordan Smith

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

extension NSView: ObservationTrackingBackfillCompatible {
  @objc func __backfill_init(frame frameRect: NSRect) -> Self {
    Self.backfillObservationTracking()
    return __backfill_init(frame: frameRect)
  }

  // MARK: - ObservationTrackingBackfillCompatible

  static var exchangedObservationSelectors: [(original: Selector, updated: Selector)] {
    [
      (#selector(layout), #selector(__backfill_layout)),
      (#selector(updateConstraints), #selector(__backfill_updateConstraints)),
      (#selector(draw(_:)), #selector(__backfill_draw(_:))),
      (#selector(updateLayer), #selector(__backfill_updateLayer))
    ]
  }

  @objc func __backfill_layout() {
    withObservationTracking {
      __backfill_layout()
    } onChange: { [weak self] in
      onMainIfNeeded { [weak self] in
        self?.needsLayout = true
      }
    }
  }

  @objc func __backfill_updateConstraints() {
    withObservationTracking {
      __backfill_updateConstraints()
    } onChange: { [weak self] in
      onMainIfNeeded { [weak self] in
        self?.needsUpdateConstraints = true
      }
    }
  }

  @objc func __backfill_draw(_ dirtyRect: NSRect) {
    withObservationTracking {
      __backfill_draw(dirtyRect)
    } onChange: { [weak self] in
      onMainIfNeeded { [weak self] in
        self?.setNeedsDisplay(dirtyRect)
      }
    }
  }

  @objc func __backfill_updateLayer() {
    withObservationTracking {
      __backfill_updateLayer()
    } onChange: { [weak self] in
      onMainIfNeeded { [weak self] in
        self?.needsDisplay = true
      }
    }
  }
}
#endif
