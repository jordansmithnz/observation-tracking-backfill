# ObservationTrackingBackfill

iOS 17 and macOS 14 include Swift Observation, but not the automatic observation tracking that later OS versions support. Automatic tracking was introduced in iOS 26 and macOS 26, with backfill only supported to the prior app version. 

Apps that support iOS 17 or macOS 14 and want to use `@Observable` models from UIKit or AppKit without manually invalidating primitives may now do so.

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
    ObservationTrackingBackfill.setup(with: .full) // Use .legacyOnly if using native backfill
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
