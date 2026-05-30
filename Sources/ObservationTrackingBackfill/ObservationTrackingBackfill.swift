// Created by Jordan Smith

import ObjectiveC

#if canImport(UIKit)
  import UIKit
#endif
#if canImport(AppKit)
  import AppKit
#endif

@MainActor
private var isSetup = false

@MainActor
public enum ObservationTrackingBackfill {
  public enum Strategy {
    /// Backfills only legacy systems, such as iOS 17 and the macOS equivalent.
    /// Native backfill behavior on iOS 18 and newer must be enabled separately.
    case legacyOnly

    /// Backfills all supported systems, including iOS 18, but does not take effect on iOS 26 and newer.
    case full

    /// Disables ObservationTrackingBackfill setup.
    case disabled
  }

  public static func setup(with strategy: Strategy = .legacyOnly) {
    guard !isSetup else { return }
    guard strategy.isEnabled else { return }

    #if canImport(UIKit)
      if strategy.shouldBackfillUIKit {
        performMethodExchange(
          UIView.self,
          #selector(UIView.init(frame:)),
          #selector(UIView.__backfill_init(frame:))
        )
        performMethodExchange(
          UIViewController.self,
          #selector(UIViewController.init(nibName:bundle:)),
          #selector(UIViewController.__backfill_init(nibName:bundle:))
        )
        performMethodExchange(
          UIPresentationController.self,
          #selector(UIPresentationController.init(presentedViewController:presenting:)),
          #selector(UIPresentationController.__backfill_init(presentedViewController:presenting:))
        )
      }
    #endif
    #if canImport(AppKit) && !targetEnvironment(macCatalyst)
      if strategy.shouldBackfillAppKit {
        performMethodExchange(
          NSView.self,
          #selector(NSView.init(frame:)),
          #selector(NSView.__backfill_init(frame:))
        )
        performMethodExchange(
          NSViewController.self,
          #selector(NSViewController.init(nibName:bundle:)),
          #selector(NSViewController.__backfill_init(nibName:bundle:))
        )
      }
    #endif
    isSetup = true
  }
}

extension ObservationTrackingBackfill.Strategy {
  fileprivate var isEnabled: Bool {
    switch self {
    case .legacyOnly, .full:
      true
    case .disabled:
      false
    }
  }

  #if canImport(UIKit)
    fileprivate var shouldBackfillUIKit: Bool {
      switch self {
      case .legacyOnly:
        if #available(iOS 18.0, tvOS 18.0, macCatalyst 18.0, *) {
          return false
        }
        return true
      case .full:
        if #available(iOS 26.0, tvOS 26.0, macCatalyst 26.0, *) {
          return false
        }
        return true
      case .disabled:
        return false
      }
    }
  #endif

  #if canImport(AppKit) && !targetEnvironment(macCatalyst)
    fileprivate var shouldBackfillAppKit: Bool {
      switch self {
      case .legacyOnly:
        if #available(macOS 15.0, *) {
          return false
        }
        return true
      case .full:
        if #available(macOS 26.0, *) {
          return false
        }
        return true
      case .disabled:
        return false
      }
    }
  #endif
}
