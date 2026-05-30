// Created by Jordan Smith

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
  import AppKit

  extension NSView: ObservationTrackingBackfillCompatible {
    // swift-format-ignore: AlwaysUseLowerCamelCase
    @objc func __backfill_init(frame frameRect: NSRect) -> Self {
      Self.backfillObservationTracking()
      return __backfill_init(frame: frameRect)
    }

    // MARK: - ObservationTrackingBackfillCompatible

    static var exchangedObservationMethods: [ObservationTrackingBackfillMethod] {
      [
        .void(#selector(layout)) { (view: NSView) in
          view.needsLayout = true
        },
        .void(#selector(updateConstraints)) { (view: NSView) in
          view.needsUpdateConstraints = true
        },
        .nsRect(#selector(draw(_:))) { (view: NSView, dirtyRect: NSRect) in
          view.setNeedsDisplay(dirtyRect)
        },
        .void(#selector(updateLayer)) { (view: NSView) in
          view.needsDisplay = true
        },
      ]
    }
  }
#endif
