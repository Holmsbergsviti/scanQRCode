import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var scannedCode: String = ""
    @State private var isPresentingScanner = false
    
    var body: some View {
        VStack {
            if scannedCode.isEmpty {
                Text("Scan a QR/Barcode")
                    .font(.title)
                    .padding()
            } else {
                Text("Scanned Code: \(scannedCode)")
                    .font(.title2)
                    .padding()
            }
            
            Spacer()
            
            Button(action: {
                isPresentingScanner = true
            }) {
                Text("Scan QR/Barcode")
                    .font(.title2)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .sheet(isPresented: $isPresentingScanner) {
                CodeScannerView(codeTypes: [.qr, .code128], completion: handleScan)
            }
            
            if !scannedCode.isEmpty {
                Button(action: {
                    if let url = URL(string: scannedCode) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Go to Link")
                        .font(.title2)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
            }
            
            Spacer()
        }
        .padding()
    }
    
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        isPresentingScanner = false
        
        switch result {
        case .success(let code):
            scannedCode = code
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
}

struct CodeScannerView: UIViewControllerRepresentable {
    var codeTypes: [AVMetadataObject.ObjectType]
    var completion: (Result<String, ScanError>) -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let captureSession = AVCaptureSession()
        let videoCaptureDevice = AVCaptureDevice.default(for: .video)
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice!)
            captureSession.addInput(videoInput)
        } catch {
            completion(.failure(.inputError))
            return viewController
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(metadataOutput)
        
        metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = codeTypes
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = viewController.view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var completion: (Result<String, ScanError>) -> Void
        
        init(completion: @escaping (Result<String, ScanError>) -> Void) {
            self.completion = completion
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first, let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject, let stringValue = readableObject.stringValue {
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                completion(.success(stringValue))
            } else {
                completion(.failure(.badOutput))
            }
        }
    }
    
    enum ScanError: Error {
        case inputError, badOutput
    }
}
