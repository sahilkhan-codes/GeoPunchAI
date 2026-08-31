import SwiftUI
import AVFoundation
import Vision

struct FaceCameraView: UIViewControllerRepresentable {
    var onFaceDetected: () -> Void
    
    func makeUIViewController(context: Context) -> FaceCameraViewController {
        let controller = FaceCameraViewController()
        controller.onFaceDetected = onFaceDetected
        return controller
    }
    
    func updateUIViewController(_ uiViewController: FaceCameraViewController, context: Context) {}
}

class FaceCameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var onFaceDetected: (() -> Void)?
    private let captureSession = AVCaptureSession()
    private var isFaceDetected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    private func setupCamera() {
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        captureSession.addInput(input)
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(output)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer), !isFaceDetected else { return }
        
        let request = VNDetectFaceLandmarksRequest { [weak self] request, error in
            if let results = request.results as? [VNFaceObservation], !results.isEmpty {
                // Face detected with high confidence
                if let firstFace = results.first, firstFace.confidence > 0.7 {
                    self?.isFaceDetected = true
                    DispatchQueue.main.async {
                        self?.captureSession.stopRunning()
                        self?.onFaceDetected?()
                    }
                }
            }
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
    }
}
