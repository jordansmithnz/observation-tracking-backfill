// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "ObservationTrackingBackfill",
  platforms: [
    .iOS(.v17),
    .macOS(.v14),
  ],
  products: [
    .library(
      name: "ObservationTrackingBackfill",
      targets: ["ObservationTrackingBackfill"]
    )
  ],
  targets: [
    .target(name: "ObservationTrackingBackfill"),
    .testTarget(
      name: "ObservationTrackingBackfillTests",
      dependencies: ["ObservationTrackingBackfill"]
    ),
  ],
  swiftLanguageModes: [.v6]
)
