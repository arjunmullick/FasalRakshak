//
//  CameraCaptureView.swift
//  FasalRakshak
//
//  Camera interface for capturing crop images for analysis
//

import SwiftUI
import AVFoundation
import PhotosUI
import Combine

struct CameraCaptureView: View {
    @EnvironmentObject var voiceAssistant: VoiceAssistantService
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var diagnosisService = CropDiagnosisService.shared

    @State private var capturedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCropSelector = false
    @State private var selectedCrop: Crop?
    @State private var isAnalyzing = false
    @State private var analysisResult: DiagnosisResult?
    @State private var showingResults = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var flashMode: AVCaptureDevice.FlashMode = .auto

    var body: some View {
        NavigationView {
            ZStack {
                // Camera Preview or Captured Image
                if let image = capturedImage {
                    capturedImageView(image)
                } else {
                    cameraPreview
                }

                // Analysis Overlay
                if isAnalyzing {
                    analysisOverlay
                }
            }
            .navigationTitle("फसल स्कैन करें")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if capturedImage != nil {
                        Button("वापस") {
                            capturedImage = nil
                            cameraManager.startSession()
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        voiceAssistant.speakHindi(VoiceAssistantService.VoiceMessages.cameraInstructionHindi)
                    }) {
                        Image(systemName: "speaker.wave.2.fill")
                    }
                }
            }
            .onAppear {
                cameraManager.checkPermissions()
                speakInstructions()
            }
            .onDisappear {
                cameraManager.stopSession()
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $capturedImage)
            }
            .sheet(isPresented: $showingCropSelector) {
                CropSelectorView(selectedCrop: $selectedCrop)
            }
            .sheet(isPresented: $showingResults) {
                if let result = analysisResult {
                    DiagnosisResultView(result: result)
                }
            }
            .alert("त्रुटि", isPresented: $showingError) {
                Button("ठीक है", role: .cancel) {}
                Button("पुनः प्रयास") {
                    if let image = capturedImage {
                        analyzeImage(image)
                    }
                }
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Camera Preview

    private var cameraPreview: some View {
        ZStack {
            CameraPreviewView(cameraManager: cameraManager)
                .ignoresSafeArea()

            // Camera Controls Overlay
            VStack {
                Spacer()

                // Guide overlay
                cameraGuideOverlay

                Spacer()

                // Bottom Controls
                cameraControls
            }
        }
    }

    // MARK: - Camera Guide Overlay

    private var cameraGuideOverlay: some View {
        VStack(spacing: 16) {
            // Instructions
            Text("प्रभावित पत्ती या पौधे को फ्रेम में रखें")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.black.opacity(0.6))
                .cornerRadius(20)

            // Guide frame
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.8), lineWidth: 2)
                .frame(width: 280, height: 280)
                .overlay(
                    // Corner markers
                    ZStack {
                        ForEach(0..<4) { corner in
                            CornerMarker()
                                .rotationEffect(.degrees(Double(corner) * 90))
                                .position(cornerPosition(corner, in: CGSize(width: 280, height: 280)))
                        }
                    }
                )

            // Tips
            HStack(spacing: 20) {
                TipBadge(icon: "sun.max", text: "अच्छी रोशनी")
                TipBadge(icon: "hand.raised", text: "स्थिर रखें")
                TipBadge(icon: "arrow.up.left.and.arrow.down.right", text: "करीब जाएं")
            }
        }
    }

    private func cornerPosition(_ corner: Int, in size: CGSize) -> CGPoint {
        switch corner {
        case 0: return CGPoint(x: 20, y: 20)
        case 1: return CGPoint(x: size.width - 20, y: 20)
        case 2: return CGPoint(x: size.width - 20, y: size.height - 20)
        case 3: return CGPoint(x: 20, y: size.height - 20)
        default: return .zero
        }
    }

    // MARK: - Camera Controls

    private var cameraControls: some View {
        VStack(spacing: 20) {
            // Flash and Gallery buttons
            HStack {
                // Gallery button
                Button(action: {
                    showingImagePicker = true
                }) {
                    VStack {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title2)
                        Text("गैलरी")
                            .font(.caption2)
                    }
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(12)
                }

                Spacer()

                // Flash toggle
                Button(action: {
                    toggleFlash()
                }) {
                    VStack {
                        Image(systemName: flashIcon)
                            .font(.title2)
                        Text(flashText)
                            .font(.caption2)
                    }
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 40)

            // Capture button
            Button(action: {
                capturePhoto()
            }) {
                ZStack {
                    Circle()
                        .stroke(Color.white, lineWidth: 4)
                        .frame(width: 80, height: 80)

                    Circle()
                        .fill(Color.white)
                        .frame(width: 68, height: 68)

                    Image(systemName: "camera.fill")
                        .font(.title)
                        .foregroundColor(.primaryGreen)
                }
            }

            // Crop selector
            Button(action: {
                showingCropSelector = true
            }) {
                HStack {
                    Image(systemName: "leaf.fill")
                    Text(selectedCrop?.nameHindi ?? "फसल चुनें (वैकल्पिक)")
                }
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.primaryGreen.opacity(0.8))
                .cornerRadius(20)
            }
        }
        .padding(.bottom, 30)
    }

    // MARK: - Captured Image View

    private func capturedImageView(_ image: UIImage) -> some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .ignoresSafeArea()

            VStack {
                Spacer()

                // Action buttons
                VStack(spacing: 16) {
                    Text("इस फोटो का विश्लेषण करें?")
                        .font(.headline)
                        .foregroundColor(.white)

                    HStack(spacing: 20) {
                        // Retake button
                        Button(action: {
                            capturedImage = nil
                            cameraManager.startSession()
                        }) {
                            VStack {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.title2)
                                Text("दोबारा लें")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                            .frame(width: 80, height: 70)
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(12)
                        }

                        // Analyze button
                        Button(action: {
                            analyzeImage(image)
                        }) {
                            VStack {
                                Image(systemName: "magnifyingglass")
                                    .font(.title2)
                                Text("विश्लेषण करें")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                            .frame(width: 120, height: 70)
                            .background(Color.primaryGreen)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(20)
                .padding()
            }
        }
    }

    // MARK: - Analysis Overlay

    private var analysisOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Animated scanning indicator
                ZStack {
                    Circle()
                        .stroke(Color.primaryGreen.opacity(0.3), lineWidth: 4)
                        .frame(width: 100, height: 100)

                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(Color.primaryGreen, lineWidth: 4)
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(isAnalyzing ? 360 : 0))
                        .animation(
                            Animation.linear(duration: 1).repeatForever(autoreverses: false),
                            value: isAnalyzing
                        )

                    Image(systemName: "leaf.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.primaryGreen)
                }

                Text("विश्लेषण हो रहा है...")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Text("कृपया प्रतीक्षा करें")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))

                // Progress bar
                ProgressView(value: diagnosisService.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .primaryGreen))
                    .frame(width: 200)
            }
        }
    }

    // MARK: - Helper Views

    private var flashIcon: String {
        switch flashMode {
        case .auto: return "bolt.badge.automatic"
        case .on: return "bolt.fill"
        case .off: return "bolt.slash"
        @unknown default: return "bolt.badge.automatic"
        }
    }

    private var flashText: String {
        switch flashMode {
        case .auto: return "ऑटो"
        case .on: return "चालू"
        case .off: return "बंद"
        @unknown default: return "ऑटो"
        }
    }

    // MARK: - Actions

    private func capturePhoto() {
        cameraManager.capturePhoto { image in
            if let image = image {
                capturedImage = image
                cameraManager.stopSession()
            }
        }
    }

    private func toggleFlash() {
        switch flashMode {
        case .auto:
            flashMode = .on
        case .on:
            flashMode = .off
        case .off:
            flashMode = .auto
        @unknown default:
            flashMode = .auto
        }
        cameraManager.setFlashMode(flashMode)
    }

    private func analyzeImage(_ image: UIImage) {
        isAnalyzing = true
        voiceAssistant.speakHindi(VoiceAssistantService.VoiceMessages.processingHindi)

        Task {
            do {
                let result = try await diagnosisService.analyzeCropImage(image, cropType: selectedCrop)
                await MainActor.run {
                    isAnalyzing = false
                    analysisResult = result
                    showingResults = true
                    voiceAssistant.speakDiagnosisResult(result)
                }
            } catch {
                await MainActor.run {
                    isAnalyzing = false
                    errorMessage = (error as? DiagnosisError)?.errorDescriptionHindi ?? "विश्लेषण में त्रुटि"
                    showingError = true
                    voiceAssistant.speakHindi(VoiceAssistantService.VoiceMessages.errorHindi)
                }
            }
        }
    }

    private func speakInstructions() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            voiceAssistant.speakHindi(VoiceAssistantService.VoiceMessages.cameraInstructionHindi)
        }
    }
}

// MARK: - Corner Marker

struct CornerMarker: View {
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 20))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 20, y: 0))
        }
        .stroke(Color.primaryGreen, lineWidth: 3)
        .frame(width: 20, height: 20)
    }
}

// MARK: - Tip Badge

struct TipBadge: View {
    let icon: String
    let text: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption2)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.5))
        .cornerRadius(8)
    }
}

// MARK: - Camera Manager

class CameraManager: NSObject, ObservableObject {
    @Published var isAuthorized = false
    @Published var isSessionRunning = false

    let session = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var photoCompletionHandler: ((UIImage?) -> Void)?

    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
            setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.isAuthorized = granted
                    if granted {
                        self?.setupSession()
                    }
                }
            }
        default:
            isAuthorized = false
        }
    }

    func setupSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        // Add video input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            session.commitConfiguration()
            return
        }

        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
            videoDeviceInput = videoInput
        }

        // Add photo output
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            photoOutput.isHighResolutionCaptureEnabled = true
        }

        session.commitConfiguration()
        startSession()
    }

    func startSession() {
        guard !session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
            DispatchQueue.main.async {
                self?.isSessionRunning = self?.session.isRunning ?? false
            }
        }
    }

    func stopSession() {
        guard session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.stopRunning()
            DispatchQueue.main.async {
                self?.isSessionRunning = false
            }
        }
    }

    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        photoCompletionHandler = completion

        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto

        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func setFlashMode(_ mode: AVCaptureDevice.FlashMode) {
        // Flash mode is set during capture
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil,
              let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            photoCompletionHandler?(nil)
            return
        }

        photoCompletionHandler?(image)
    }
}

// MARK: - Camera Preview View

struct CameraPreviewView: UIViewRepresentable {
    @ObservedObject var cameraManager: CameraManager

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)

        let previewLayer = AVCaptureVideoPreviewLayer(session: cameraManager.session)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let layer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            layer.frame = uiView.bounds
        }
    }
}

// MARK: - Image Picker

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()

            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else {
                return
            }

            provider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                DispatchQueue.main.async {
                    self?.parent.image = image as? UIImage
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    CameraCaptureView()
        .environmentObject(VoiceAssistantService.shared)
}
