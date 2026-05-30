// Created by Jordan Smith

import Foundation
import ObjectiveC
import os

#if canImport(UIKit)
  import UIKit
#endif
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
  import AppKit
#endif

struct ObservationTrackingBackfillMethod {
  let selector: Selector
  let install: (AnyClass) -> Void

  static func void<T: AnyObject>(
    _ selector: Selector,
    onChange: @escaping @MainActor (T) -> Void
  ) -> Self {
    Self(selector: selector) { type in
      installVoidWrapper(type, selector, onChange: onChange)
    }
  }

  #if canImport(UIKit)
    static func cgRect<T: AnyObject>(
      _ selector: Selector,
      onChange: @escaping @MainActor (T, CGRect) -> Void
    ) -> Self {
      Self(selector: selector) { type in
        installCGRectWrapper(type, selector, onChange: onChange)
      }
    }

    static func uiCellConfigurationState<T: AnyObject>(
      _ selector: Selector,
      onChange: @escaping @MainActor (T, UICellConfigurationState) -> Void
    ) -> Self {
      Self(selector: selector) { type in
        installUICellConfigurationStateWrapper(type, selector, onChange: onChange)
      }
    }

    static func uiViewConfigurationState<T: AnyObject>(
      _ selector: Selector,
      onChange: @escaping @MainActor (T, UIViewConfigurationState) -> Void
    ) -> Self {
      Self(selector: selector) { type in
        installUIViewConfigurationStateWrapper(type, selector, onChange: onChange)
      }
    }

    static func uiContentUnavailableConfigurationState<T: AnyObject>(
      _ selector: Selector,
      onChange: @escaping @MainActor (T, UIContentUnavailableConfigurationState) -> Void
    ) -> Self {
      Self(selector: selector) { type in
        installUIContentUnavailableConfigurationStateWrapper(type, selector, onChange: onChange)
      }
    }
  #endif

  #if canImport(AppKit) && !targetEnvironment(macCatalyst)
    static func nsRect<T: AnyObject>(
      _ selector: Selector,
      onChange: @escaping @MainActor (T, NSRect) -> Void
    ) -> Self {
      Self(selector: selector) { type in
        installNSRectWrapper(type, selector, onChange: onChange)
      }
    }
  #endif
}

private struct OriginalImplementationKey: Hashable {
  let type: ObjectIdentifier
  let selector: String
}

private final class OriginalImplementationRegistry: @unchecked Sendable {
  static let shared = OriginalImplementationRegistry()

  private let implementations = OSAllocatedUnfairLock(
    initialState: [OriginalImplementationKey: UInt]()
  )

  func contains(_ type: AnyClass, _ selector: Selector) -> Bool {
    implementations.withLock {
      $0[Self.key(type, selector)] != nil
    }
  }

  func insert(_ implementation: IMP, for type: AnyClass, _ selector: Selector) {
    let pointer = UInt(bitPattern: implementation)
    implementations.withLock {
      $0[Self.key(type, selector)] = pointer
    }
  }

  func implementation(for type: AnyClass, _ selector: Selector) -> IMP? {
    guard
      let pointer = implementations.withLock({
        $0[Self.key(type, selector)]
      })
    else {
      return nil
    }

    return IMP(bitPattern: pointer)
  }

  private static func key(_ type: AnyClass, _ selector: Selector) -> OriginalImplementationKey {
    OriginalImplementationKey(
      type: ObjectIdentifier(type),
      selector: NSStringFromSelector(selector)
    )
  }
}

private final class WeakObjectBox: @unchecked Sendable {
  weak var object: AnyObject?

  init(_ object: AnyObject) {
    self.object = object
  }
}

private final class SendableValueBox<Value>: @unchecked Sendable {
  let value: Value

  init(_ value: Value) {
    self.value = value
  }
}

private func replaceImplementation(
  of selector: Selector,
  on type: AnyClass,
  with makeWrapper: () -> IMP
) {
  guard
    !OriginalImplementationRegistry.shared.contains(type, selector),
    let method = class_getInstanceMethod(type, selector)
  else {
    return
  }

  OriginalImplementationRegistry.shared.insert(
    method_getImplementation(method), for: type, selector)
  method_setImplementation(method, makeWrapper())
}

private typealias VoidImplementation = @convention(c) (AnyObject, Selector) -> Void
private typealias CGRectImplementation = @convention(c) (AnyObject, Selector, CGRect) -> Void
#if canImport(UIKit)
  private typealias UICellConfigurationStateImplementation =
    @convention(c) (AnyObject, Selector, UICellConfigurationState) -> Void
  private typealias UIViewConfigurationStateImplementation =
    @convention(c) (AnyObject, Selector, UIViewConfigurationState) -> Void
  private typealias UIContentUnavailableConfigurationStateImplementation =
    @convention(c) (AnyObject, Selector, UIContentUnavailableConfigurationState) -> Void
#endif
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
  private typealias NSRectImplementation = @convention(c) (AnyObject, Selector, NSRect) -> Void
#endif

private func originalImplementation(
  for type: AnyClass,
  _ selector: Selector
) -> IMP? {
  OriginalImplementationRegistry.shared.implementation(for: type, selector)
}

private func callOriginalVoidImplementation(
  _ type: AnyClass,
  _ selector: Selector,
  _ object: AnyObject
) {
  guard let implementation = originalImplementation(for: type, selector) else { return }
  unsafeBitCast(implementation, to: VoidImplementation.self)(object, selector)
}

private func callOriginalCGRectImplementation(
  _ type: AnyClass,
  _ selector: Selector,
  _ object: AnyObject,
  _ rect: CGRect
) {
  guard let implementation = originalImplementation(for: type, selector) else { return }
  unsafeBitCast(implementation, to: CGRectImplementation.self)(object, selector, rect)
}

#if canImport(UIKit)
  private func callOriginalUICellConfigurationStateImplementation(
    _ type: AnyClass,
    _ selector: Selector,
    _ object: AnyObject,
    _ state: UICellConfigurationState
  ) {
    guard let implementation = originalImplementation(for: type, selector) else { return }
    unsafeBitCast(implementation, to: UICellConfigurationStateImplementation.self)(
      object, selector, state)
  }

  private func callOriginalUIViewConfigurationStateImplementation(
    _ type: AnyClass,
    _ selector: Selector,
    _ object: AnyObject,
    _ state: UIViewConfigurationState
  ) {
    guard let implementation = originalImplementation(for: type, selector) else { return }
    unsafeBitCast(implementation, to: UIViewConfigurationStateImplementation.self)(
      object, selector, state)
  }

  private func callOriginalUIContentUnavailableConfigurationStateImplementation(
    _ type: AnyClass,
    _ selector: Selector,
    _ object: AnyObject,
    _ state: UIContentUnavailableConfigurationState
  ) {
    guard let implementation = originalImplementation(for: type, selector) else { return }
    unsafeBitCast(implementation, to: UIContentUnavailableConfigurationStateImplementation.self)(
      object, selector, state)
  }
#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
  private func callOriginalNSRectImplementation(
    _ type: AnyClass,
    _ selector: Selector,
    _ object: AnyObject,
    _ rect: NSRect
  ) {
    guard let implementation = originalImplementation(for: type, selector) else { return }
    unsafeBitCast(implementation, to: NSRectImplementation.self)(object, selector, rect)
  }
#endif

private func installVoidWrapper<T: AnyObject>(
  _ type: AnyClass,
  _ selector: Selector,
  onChange: @escaping @MainActor (T) -> Void
) {
  let wrappedType: AnyClass = type
  let block: @convention(block) (AnyObject) -> Void = { object in
    let objectBox = WeakObjectBox(object)
    withObservationTracking {
      callOriginalVoidImplementation(wrappedType, selector, object)
    } onChange: {
      onMainIfNeeded {
        guard let target = objectBox.object as? T else { return }
        onChange(target)
      }
    }
  }

  replaceImplementation(of: selector, on: type) {
    imp_implementationWithBlock(block)
  }
}

private func installCGRectWrapper<T: AnyObject>(
  _ type: AnyClass,
  _ selector: Selector,
  onChange: @escaping @MainActor (T, CGRect) -> Void
) {
  let wrappedType: AnyClass = type
  let block: @convention(block) (AnyObject, CGRect) -> Void = { object, rect in
    let objectBox = WeakObjectBox(object)
    withObservationTracking {
      callOriginalCGRectImplementation(wrappedType, selector, object, rect)
    } onChange: {
      onMainIfNeeded {
        guard let target = objectBox.object as? T else { return }
        onChange(target, rect)
      }
    }
  }

  replaceImplementation(of: selector, on: type) {
    imp_implementationWithBlock(block)
  }
}

#if canImport(UIKit)
  private func installUICellConfigurationStateWrapper<T: AnyObject>(
    _ type: AnyClass,
    _ selector: Selector,
    onChange: @escaping @MainActor (T, UICellConfigurationState) -> Void
  ) {
    let wrappedType: AnyClass = type
    let block: @convention(block) (AnyObject, UICellConfigurationState) -> Void = { object, state in
      let objectBox = WeakObjectBox(object)
      let stateBox = SendableValueBox(state)
      withObservationTracking {
        callOriginalUICellConfigurationStateImplementation(wrappedType, selector, object, state)
      } onChange: {
        onMainIfNeeded {
          guard let target = objectBox.object as? T else { return }
          onChange(target, stateBox.value)
        }
      }
    }

    replaceImplementation(of: selector, on: type) {
      imp_implementationWithBlock(block)
    }
  }

  private func installUIViewConfigurationStateWrapper<T: AnyObject>(
    _ type: AnyClass,
    _ selector: Selector,
    onChange: @escaping @MainActor (T, UIViewConfigurationState) -> Void
  ) {
    let wrappedType: AnyClass = type
    let block: @convention(block) (AnyObject, UIViewConfigurationState) -> Void = { object, state in
      let objectBox = WeakObjectBox(object)
      let stateBox = SendableValueBox(state)
      withObservationTracking {
        callOriginalUIViewConfigurationStateImplementation(wrappedType, selector, object, state)
      } onChange: {
        onMainIfNeeded {
          guard let target = objectBox.object as? T else { return }
          onChange(target, stateBox.value)
        }
      }
    }

    replaceImplementation(of: selector, on: type) {
      imp_implementationWithBlock(block)
    }
  }

  private func installUIContentUnavailableConfigurationStateWrapper<T: AnyObject>(
    _ type: AnyClass,
    _ selector: Selector,
    onChange: @escaping @MainActor (T, UIContentUnavailableConfigurationState) -> Void
  ) {
    let wrappedType: AnyClass = type
    let block: @convention(block) (AnyObject, UIContentUnavailableConfigurationState) -> Void = {
      object, state in
      let objectBox = WeakObjectBox(object)
      let stateBox = SendableValueBox(state)
      withObservationTracking {
        callOriginalUIContentUnavailableConfigurationStateImplementation(
          wrappedType, selector, object, state)
      } onChange: {
        onMainIfNeeded {
          guard let target = objectBox.object as? T else { return }
          onChange(target, stateBox.value)
        }
      }
    }

    replaceImplementation(of: selector, on: type) {
      imp_implementationWithBlock(block)
    }
  }
#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
  private func installNSRectWrapper<T: AnyObject>(
    _ type: AnyClass,
    _ selector: Selector,
    onChange: @escaping @MainActor (T, NSRect) -> Void
  ) {
    let wrappedType: AnyClass = type
    let block: @convention(block) (AnyObject, NSRect) -> Void = { object, rect in
      let objectBox = WeakObjectBox(object)
      withObservationTracking {
        callOriginalNSRectImplementation(wrappedType, selector, object, rect)
      } onChange: {
        onMainIfNeeded {
          guard let target = objectBox.object as? T else { return }
          onChange(target, rect)
        }
      }
    }

    replaceImplementation(of: selector, on: type) {
      imp_implementationWithBlock(block)
    }
  }
#endif
