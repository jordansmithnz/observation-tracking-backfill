// Created by Jordan Smith

import Foundation
import ObjectiveC

func onMainIfNeeded(_ action: @MainActor @escaping () -> Void) {
  if Thread.isMainThread {
    MainActor.assumeIsolated {
      action()
    }
  } else {
    DispatchQueue.main.async {
      action()
    }
  }
}

func performMethodExchange(
  _ type: AnyClass,
  _ originalSelector: Selector,
  _ updatedSelector: Selector
) {
  guard
    let originalMethod = class_getInstanceMethod(type, originalSelector),
    let updatedMethod = class_getInstanceMethod(type, updatedSelector)
  else {
    return
  }

  method_exchangeImplementations(originalMethod, updatedMethod)
}

func implementsSelector(_ type: AnyClass, _ selector: Selector) -> Bool {
  guard
    let method = class_getInstanceMethod(type, selector),
    let superclass = class_getSuperclass(type),
    let superMethod = class_getInstanceMethod(superclass, selector)
  else {
    return false
  }

  return method_getImplementation(method) != method_getImplementation(superMethod)
}
