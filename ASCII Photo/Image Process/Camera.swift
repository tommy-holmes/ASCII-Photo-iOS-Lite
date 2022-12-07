import AVFoundation

enum CameraError: LocalizedError {
    case notAuthorized
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized: return "Camera permission not authorized."
        }
    }
}

final class Camera {
    private let captureSession = AVCaptureSession()
    private var isCaptureSessionConfigured = false
    private var deviceInput: AVCaptureDeviceInput?
    private var photoOutput: AVCapturePhotoOutput?
    private var sessionQueue: DispatchQueue!
    
    private var allCaptureDevices: [AVCaptureDevice] {
        AVCaptureDevice.DiscoverySession(deviceTypes: [
            .builtInTrueDepthCamera, .builtInDualCamera,
            .builtInDualWideCamera, .builtInWideAngleCamera
        ], mediaType: .video, position: .unspecified).devices
    }
    
    private var frontCaptureDevices: [AVCaptureDevice] {
        allCaptureDevices
            .filter { $0.position == .front }
    }
    
    private var backCaptureDevices: [AVCaptureDevice] {
        allCaptureDevices
            .filter { $0.position == .back }
    }
    
    private var availableCaptureDevices: [AVCaptureDevice] {
        var devices = [AVCaptureDevice]()
        
        if let backDevice = backCaptureDevices.first {
            devices += [backDevice]
        }
        if let frontDevice = frontCaptureDevices.first {
            devices += [frontDevice]
        }
        return devices
            .filter(\.isConnected)
            .filter { !$0.isSuspended }
    }
    
    private var captureDevice: AVCaptureDevice? {
        didSet {
            guard let captureDevice = captureDevice else { return }
            sessionQueue.async {
                self.updateSessionForCaptureDevice(captureDevice)
            }
        }
    }
    
    private var addToPhotoStream: ((AVCapturePhoto) -> Void)?
    
    lazy var photoStream: AsyncStream<AVCapturePhoto> = {
        AsyncStream { continuation in
            addToPhotoStream = { photo in
                continuation.yield(photo)
            }
        }
    }()
    
    init() {
        sessionQueue = DispatchQueue(label: "session queue")
        captureDevice = availableCaptureDevices.first ?? AVCaptureDevice.default(for: .video)
    }
    
    func start() async throws {
        guard await checkAuthorization() else { throw CameraError.notAuthorized }
        
        if isCaptureSessionConfigured {
            if !captureSession.isRunning {
                sessionQueue.async { [weak self] in
                    self?.captureSession.startRunning()
                }
            }
            return
        }
        
        if await configuredCaptureSession() { // Potential issue if I need to use the DispatchQueue rather than async/await
            captureSession.startRunning()
        }
    }
    
    func stop() {
        guard isCaptureSessionConfigured else { return }
        
        if captureSession.isRunning {
            sessionQueue.async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func takePhoto() {
        guard let photoOutput else { return }
        
        sessionQueue.async {
            var settings = AVCapturePhotoSettings()
            
            if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
                settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
            }
            let isFlashAvaliable = self.deviceInput?.device.isFlashAvailable ?? false
            settings.flashMode = isFlashAvaliable ? .auto : .off
            
            if let previewPhotoPixelFormatType = settings.availablePreviewPhotoPixelFormatTypes.first {
                settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
            }
            settings.photoQualityPrioritization = .balanced
            
            let processor = PhotoCaptureProcessor { photo in
                self.addToPhotoStream?(photo)
            }
            photoOutput.capturePhoto(with: settings, delegate: processor)
        }
    }
    
    private func configuredCaptureSession() async -> Bool {
        self.captureSession.beginConfiguration()
        
        defer { self.captureSession.commitConfiguration() }
        
        guard
            let captureDevice = captureDevice,
            let deviceInput = try? AVCaptureDeviceInput(device: captureDevice)
        else {
            return false
        }
        
        let photoOutput = AVCapturePhotoOutput()
        photoOutput.isLivePhotoCaptureEnabled = false
        
        captureSession.sessionPreset = .photo
        
        guard captureSession.canAddInput(deviceInput) else {
            print("Unable to add device input to capture session.")
            return false
        }
        guard captureSession.canAddOutput(photoOutput) else {
            print("Unable to add photo output to capture session.")
            return false
        }
        
        captureSession.addInput(deviceInput)
        captureSession.addOutput(photoOutput)
        
        self.deviceInput = deviceInput
        self.photoOutput = photoOutput
        
        photoOutput.maxPhotoQualityPrioritization = .quality
        
        isCaptureSessionConfigured = true
        
        return true
    }
    
    private func deviceInputFor(device: AVCaptureDevice?) -> AVCaptureDeviceInput? {
        guard let validDevice = device else { return nil }
        do {
            return try AVCaptureDeviceInput(device: validDevice)
        } catch let error {
            print("Error getting capture device input: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func updateSessionForCaptureDevice(_ captureDevice: AVCaptureDevice) {
        guard isCaptureSessionConfigured else { return }
        
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }
        
        for input in captureSession.inputs {
            if let deviceInput = input as? AVCaptureDeviceInput {
                captureSession.removeInput(deviceInput)
            }
        }
        
        if let deviceInput = deviceInputFor(device: captureDevice) {
            if !captureSession.inputs.contains(deviceInput), captureSession.canAddInput(deviceInput) {
                captureSession.addInput(deviceInput)
            }
        }
    }
    
    private func checkAuthorization() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            print("Camera access authorized.")
            return true
        case .notDetermined:
            print("Camera access not determined.")
            sessionQueue.suspend()
            let status = await AVCaptureDevice.requestAccess(for: .video)
            sessionQueue.resume()
            return status
        case .denied:
            print("Camera access denied.")
            return false
        case .restricted:
            print("Camera library access restricted.")
            return false
        @unknown default:
            return false
        }
    }
}

private final class PhotoCaptureProcessor: NSObject, AVCapturePhotoCaptureDelegate {
    let completion: (AVCapturePhoto) -> Void
    
    init(completion: @escaping (AVCapturePhoto) -> Void) {
        self.completion = completion
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error {
            print(error)
            return
        }
        completion(photo)
    }
}
