# ObservationTrackingBackfill

ObservationTrackingBackfill brings UIKit and AppKit automatic observation tracking back to systems where Swift Observation exists but native view tracking is missing.

iOS 17 and macOS 14 include Swift Observation, but UIKit and AppKit do not automatically track observable model reads in view, view controller, and configuration update methods. ObservationTrackingBackfill fills that gap by tracking observable values read inside supported callbacks and invalidating the right update pass when those values change.

This is intended for apps that support iOS 17 or macOS 14 and want to use `@Observable` models from UIKit or AppKit without manually calling `setNeedsLayout()`, `setNeedsUpdateConfiguration()`, or similar invalidation methods after every model mutation.

## Requirements

- iOS 17.0+
- macOS 14.0+
- Swift 6 language mode
- Xcode 16 or newer

## Installation

Add this package with Swift Package Manager:

```swift
.package(url: "https://github.com/<owner>/observation-tracking-backfill.git", from: "0.1.0")
```

Then add `ObservationTrackingBackfill` to your app target.

## Usage

Call setup once when the app starts:

```swift
import ObservationTrackingBackfill
import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    ObservationTrackingBackfill.setup(with: .legacyOnly)
    return true
  }
}
```

Read observable model state from a supported UIKit callback:

```swift
import Observation
import UIKit

@Observable
final class Counter {
  var value = 0
}

final class CounterView: UIView {
  let counter: Counter

  init(counter: Counter) {
    self.counter = counter
    super.init(frame: .zero)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    backgroundColor = counter.value.isMultiple(of: 2) ? .systemBlue : .systemGreen
  }
}
```

ObservationTrackingBackfill follows the automatic observation tracking behavior from iOS 26 and macOS 26, backfilling the same method-based update points where possible on older systems.

## Demo

Open `ObservationTrackingBackfill.xcworkspace` and run the `ObservationTrackingBackfillDemo` scheme. The demo is a UIKit grocery list app using a collection view, observable model state, and a local Swift package reference to this framework.

## Repository Layout

```text
Sources/
  ObservationTrackingBackfill/
Examples/
  ObservationTrackingBackfillDemo/
    ObservationTrackingBackfillDemo.xcodeproj
ObservationTrackingBackfill.xcworkspace
Package.swift
README.md
```

Swift Package Manager only builds the library target at `Sources/ObservationTrackingBackfill`; the demo project is not part of the package.
