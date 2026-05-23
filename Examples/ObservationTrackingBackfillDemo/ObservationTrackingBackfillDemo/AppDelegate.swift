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

    let window = UIWindow(frame: UIScreen.main.bounds)
    window.rootViewController = GroceryListViewController()
    window.makeKeyAndVisible()
    self.window = window

    return true
  }
}
