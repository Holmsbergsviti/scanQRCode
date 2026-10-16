# QR & Barcode Scanner

A small iOS app that reads QR codes and Code 128 barcodes with the iPhone camera and, when the
payload is a link, opens it in one tap.

## How it works

- **Camera pipeline** — `CodeScannerView` wraps a UIKit view controller in SwiftUI
  (`UIViewControllerRepresentable`). It builds an `AVCaptureSession` from the default video device,
  attaches an `AVCaptureMetadataOutput` restricted to `.qr` and `.code128`, and shows the live feed
  through an `AVCaptureVideoPreviewLayer`.
- **Decoding** — a `Coordinator` acts as the `AVCaptureMetadataOutputObjectsDelegate`. The first
  machine-readable object's `stringValue` is returned through a `Result<String, ScanError>`
  completion, with a haptic buzz on success, and the scanner sheet closes.
- **Acting on the result** — the scanned value is shown on screen; if it parses as a `URL`,
  a *Go to Link* button opens it with `UIApplication.shared.open`.
- **VisionKit scanner** — `DataScannerRepresentable` is a second, newer scanner built on
  `DataScannerViewController` (iOS 16+), which recognises barcodes *and* printed text, tracks
  multiple items at a high frame rate and supports pinch-to-zoom. It is written but not yet wired
  into the main screen.

## Tech stack

Swift · SwiftUI · AVFoundation · VisionKit · iOS 17 deployment target

## Project structure

```
Barcode Scanner.xcodeproj/
Barcode Scanner/
├── Barcode_ScannerApp.swift        app entry point
├── ContentView.swift               main screen + AVFoundation scanner
├── DataScannerRepresentable.swift  VisionKit scanner (barcodes + text)
└── Assets.xcassets/                app icon and colours
```

## Running it

1. Open `Barcode Scanner.xcodeproj` in Xcode 15 or later.
2. Pick a **physical iPhone** as the run destination — the simulator has no camera.
3. Set your own development team under *Signing & Capabilities*, then press **Run** (⌘R).

## Author

Vladislav Salii
