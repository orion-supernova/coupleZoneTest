//
//  CustomCameraViewController.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 12.11.2023.
//

import UIKit
import AVFoundation
import SnapKit

protocol CustomCameraViewControllerDelegate: AnyObject {
    func didSendPhoto(image: UIImage)
    func didCancel()
}

class CustomCameraViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    // MARK: - UI Elements
    private var mainContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    private lazy var captureButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.tintColor = .white
        button.backgroundColor = .LilacClouds.lilac1
        button.addTarget(self, action: #selector(captureButtonAction), for: .touchUpInside)
        return button
    }()
    private lazy var switchCameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.triangle.2.circlepath"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .LilacClouds.lilac1
        button.addTarget(self, action: #selector(switchCameraButtonAction), for: .touchUpInside)
        return button
    }()
    private lazy var closeCameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .LilacClouds.lilac1
        button.addTarget(self, action: #selector(closeCameraButtonAction), for: .touchUpInside)
        return button
    }()
    private lazy var angleLensButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("1.0", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        button.tintColor = .white
        button.backgroundColor = .LilacClouds.lilac1
        button.isHidden = true
        button.addTarget(self, action: #selector(angleLensButtonAction), for: .touchUpInside)
        return button
    }()
    private lazy var sendPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "paperplane"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.tintColor = .white
        button.backgroundColor = .LilacClouds.lilac1
        button.isHidden = true
        button.addTarget(self, action: #selector(sendPhotoButtonAction), for: .touchUpInside)
        return button
    }()
    private lazy var retakePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.counterclockwise"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .LilacClouds.lilac1
        button.isHidden = true
        button.addTarget(self, action: #selector(retakePhotoButtonAction), for: .touchUpInside)
        return button
    }()
    private lazy var capturedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    // MARK: - Private Properties
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private let borderLayer = CALayer()
    private var currentCamera: AVCaptureDevice?

    // MARK: - Public Properties
    weak var delegate: CustomCameraViewControllerDelegate?

    // MARK: - Lifecycle
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = .systemBackground
        setup()
        layout()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        view.subviews.forEach({ view.bringSubviewToFront($0) })
        addGestureRecognizers()
        enableNightModeIfLowLight()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        captureButton.round(corners: .allCorners, radius: captureButton.frame.size.width/2)
        switchCameraButton.round(corners: .allCorners, radius: switchCameraButton.frame.size.width/2)
        closeCameraButton.round(corners: .allCorners, radius: closeCameraButton.frame.size.width/2)
        angleLensButton.round(corners: .allCorners, radius: angleLensButton.frame.size.width/2)
        sendPhotoButton.round(corners: .allCorners, radius: sendPhotoButton.frame.size.width/2)
        retakePhotoButton.round(corners: .allCorners, radius: retakePhotoButton.frame.size.width/2)
    }

    // MARK: - Setup Camera
    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo

        guard let cameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
        guard let input = try? AVCaptureDeviceInput(device: cameraDevice) else { return }

        // Add the new input to the session
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        // Add an output for photo take action
        let photoOutput = AVCapturePhotoOutput()
        photoOutput.isHighResolutionCaptureEnabled = true
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        // Configure mirroring
        if let photoOutput = captureSession.outputs.first as? AVCapturePhotoOutput {
            if let connection = photoOutput.connection(with: .video),
               connection.isVideoMirroringSupported {
                connection.automaticallyAdjustsVideoMirroring = false
                connection.isVideoMirrored = true
            }
        }
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)

        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }

    // MARK: - Setup
    @MainActor private func setup() {
        view.addSubview(captureButton)
        view.addSubview(switchCameraButton)
        view.addSubview(closeCameraButton)
        view.addSubview(angleLensButton)
        view.addSubview(sendPhotoButton)
        view.addSubview(retakePhotoButton)
    }
    @MainActor private func layout() {
        captureButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.size.equalTo(70)
        }
        switchCameraButton.snp.makeConstraints { make in
            make.centerY.equalTo(captureButton.snp.centerY)
            make.right.equalTo(-20)
            make.size.equalTo(40)
        }
        closeCameraButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.equalTo(20)
            make.size.equalTo(30)
        }
        angleLensButton.snp.makeConstraints { make in
            make.bottom.equalTo(captureButton.snp.top).offset(-20)
            make.centerX.equalToSuperview()
            make.size.equalTo(30)
        }
        sendPhotoButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.size.equalTo(70)
        }
        retakePhotoButton.snp.makeConstraints { make in
            make.centerY.equalTo(captureButton.snp.centerY)
            make.left.equalTo(20)
            make.size.equalTo(40)
        }
    }
    // MARK: - Gesture(s)
    private func addGestureRecognizers() {
        // Double Tap
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTapGestureRecognizer)
        // Single Tap
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(singleTapAction(_:)))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(singleTapGestureRecognizer)
    }
    @objc private func doubleTapAction() {
        hideFocusIndicator()
        switchCameraButtonAction()
    }
    @objc private func singleTapAction(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput else { return }
        let currentPosition = currentInput.device.position
        guard currentPosition == .back else { return }
        hideFocusIndicator()
        let tapPoint = gestureRecognizer.location(in: self.view)
        // Convert the tapPoint to a camera focus point
        let focusPoint = CGPoint(x: tapPoint.x / previewLayer.bounds.size.width, y: tapPoint.y / previewLayer.bounds.size.height)
        focus(with: .autoFocus, exposureMode: .autoExpose, at: focusPoint)
    }
    private func removeGestureRecognizers() {
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                view.removeGestureRecognizer(recognizer)
            }
        }
    }

    // MARK: - Actions
    @objc private func closeCameraButtonAction() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
        self.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.delegate?.didCancel()
            print(captureSession.isRunning)
        }
    }
    @objc private func captureButtonAction() {
        guard let photoOutput = captureSession.outputs.first as? AVCapturePhotoOutput else { return }
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = true
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
        removeGestureRecognizers()
    }
    @objc private func sendPhotoButtonAction() {
        guard let image = capturedImageView.image else {
            displaySimpleAlert(title: "Error", message: "Please try again later.", okButtonText: "OK")
            return
        }
        displayAlertTwoButtons(title: "Ready?", message: "Do you want to send this picture?", firstButtonText: "Yeap!", firstButtonStyle: .default, seconButtonText: "Nope.", secondButtonStyle: .cancel, firstButtonCompletion:  {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
            self.dismiss(animated: true) { [weak self] in
                guard let self else { return }
                self.delegate?.didSendPhoto(image: image)
            }
        })

    }
    @objc private func retakePhotoButtonAction() {
        addGestureRecognizers()
        capturedImageView.alpha = 1
        updateButtons(photoTaken: false)
        UIView.animate(withDuration: 0.5, animations: {
            self.capturedImageView.alpha = 0 // Fade out the image view
        }) { _ in
            self.capturedImageView.snp.removeConstraints()
            self.capturedImageView.removeFromSuperview()
            self.capturedImageView.alpha = 1 // Reset the alpha for future display
        }
    }
    // MARK: - Low Light
    func enableNightModeIfLowLight() {
        guard let device = AVCaptureDevice.default(for: .video) else {
            return
        }

        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }

            if device.isLowLightBoostSupported && device.isLowLightBoostEnabled {
                // Low light detected, night mode is already enabled
                print("Low light detected. Night mode is already enabled.")
                return
            }

            if device.isLowLightBoostSupported {
                // Low light detected, enabling night mode
                device.automaticallyEnablesLowLightBoostWhenAvailable = true
                print("Low light detected. Night mode enabled.")
            } else {
                print("Night mode not supported.")
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }


    // MARK: - Switch Camera
    @objc private func switchCameraButtonAction() {
        guard let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput else { return }
        let currentPosition = currentInput.device.position
        let newPosition: AVCaptureDevice.Position = (currentPosition == .back) ? .front : .back

        // Animating the view transition on the main thread
        DispatchQueue.main.async {
            UIView.transition(with: self.view, duration: 0.6, options: .transitionFlipFromLeft) {
                self.previewLayer.isHidden = true
                self.angleLensButton.isHidden = newPosition == .front
                // No changes needed here, only the view transition animation
            } completion: { _ in
                self.previewLayer.isHidden = false
            }
        }

        // Performing camera configuration changes in the background
        DispatchQueue.global().async {
            // Find an available camera with the new position
            guard let newCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition) else { return }

            // Begin configuration changes
            self.captureSession.beginConfiguration()
            // Remove the current input
            self.captureSession.removeInput(currentInput)

            do {
                let newInput = try AVCaptureDeviceInput(device: newCamera)

                // Add the new input to the session
                if self.captureSession.canAddInput(newInput) {
                    self.captureSession.addInput(newInput)
                }

                // Configure photo output mirroring for front camera
                if let photoOutput = self.captureSession.outputs.first as? AVCapturePhotoOutput {
                    if let connection = photoOutput.connection(with: .video),
                       connection.isVideoMirroringSupported {
                        connection.automaticallyAdjustsVideoMirroring = false
                        connection.isVideoMirrored = (newPosition == .front)
                    }
                }
            } catch {
                print("Error creating AVCaptureDeviceInput: \(error.localizedDescription)")
            }

            // Commit the configuration changes
            self.captureSession.commitConfiguration()
        }
    }

//    // MARK: - Switch Lens
    @objc private func angleLensButtonAction() {
        guard let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput else {
            return
        }
        let lensTypes: [AVCaptureDevice.DeviceType] = [.builtInUltraWideCamera, .builtInWideAngleCamera, .builtInTelephotoCamera]
        let currentDeviceType = currentInput.device.deviceType

        // Find the index of the current lens
        if let currentIndex = lensTypes.firstIndex(of: currentDeviceType) {
            let nextIndex = (currentIndex + 1) % lensTypes.count
            let nextDeviceType = lensTypes[nextIndex]
            let _: Int = Int(currentInput.device.videoZoomFactor)

            // Calculate the scale factor based on lens types
            var scale: CGFloat = 1.0 // Default, no zoom effect
//            switch currentDeviceType {
//                case .builtInWideAngleCamera:
//                    scale = 3.0
//                case .builtInTelephotoCamera:
//                    scale = 1/6
//                case .builtInUltraWideCamera:
//                    scale = 2
//                default:
//                    scale = 1
//            }
            UIView.animate(withDuration: 0.0, animations: {
                self.previewLayer.setAffineTransform(CGAffineTransform(scaleX: scale, y: scale))
            }) { _ in
                self.switchToNextLens(currentInput: currentInput, nextDeviceType: nextDeviceType)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {

                    self.updateLensButtonTitle(for: nextDeviceType)
                }
            }

        }
    }

    private func switchToNextLens(currentInput: AVCaptureDeviceInput, nextDeviceType: AVCaptureDevice.DeviceType) {
        DispatchQueue.global().async {
            if let newCamera = AVCaptureDevice.default(nextDeviceType, for: .video, position: currentInput.device.position) {
                self.captureSession.beginConfiguration()
                self.captureSession.removeInput(currentInput)

                do {
                    let newInput = try AVCaptureDeviceInput(device: newCamera)

                    if self.captureSession.canAddInput(newInput) {
                        self.captureSession.addInput(newInput)
                    }

                    if let photoOutput = self.captureSession.outputs.first as? AVCapturePhotoOutput {
                        if let connection = photoOutput.connection(with: .video),
                           connection.isVideoMirroringSupported {
                            connection.automaticallyAdjustsVideoMirroring = false
                            connection.isVideoMirrored = (newCamera.position == .front)
                        }
                    }
                } catch {
                    print("Error creating AVCaptureDeviceInput: \(error.localizedDescription)")
                }

                self.captureSession.commitConfiguration()

                // Reset the transformation to its original state
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.0) {
                        self.previewLayer.setAffineTransform(.identity)
                    }
                }
            }
        }
    }
    // MARK: - Focus
    private func focus(with focusMode: AVCaptureDevice.FocusMode, exposureMode: AVCaptureDevice.ExposureMode, at point: CGPoint) {
        guard let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput else {
            return
        }

        let device = currentInput.device

        do {
            try device.lockForConfiguration()

            if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                device.focusPointOfInterest = point
                device.focusMode = focusMode
            }

            if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                device.exposurePointOfInterest = point
                device.exposureMode = exposureMode
            }

            device.unlockForConfiguration()

            // Show a focus indicator (e.g., an image or animation)
            showFocusIndicator(at: point)

            // Dispatch a delay to hide the focus indicator after 1 second
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.hideFocusIndicator()
            }
        } catch {
            print("Failed to focus: \(error.localizedDescription)")
        }
    }

    private func showFocusIndicator(at point: CGPoint) {
        // Show your focus indicator (e.g., an image) at the specified point on the previewLayer
        // You can animate its appearance or simply add it as a subview with a specific location
        // For example:
        let focusImage = FocusIndicatorImageView(image: UIImage(systemName: "camera.aperture"))
        focusImage.center = CGPoint(x: point.x * previewLayer.bounds.width, y: point.y * previewLayer.bounds.height)
        focusImage.frame.size = CGSize(width: 40, height: 40)
        focusImage.tintColor = .LilacClouds.lilac1
        view.addSubview(focusImage)
    }

    private func hideFocusIndicator() {
        // Hide or remove the focus indicator after focusing
        // For example:
        for subview in view.subviews {
            if let focusImage = subview as? FocusIndicatorImageView {
                focusImage.removeFromSuperview()
            }
        }
    }

    // MARK: - Update Lens Button
    private func updateLensButtonTitle(for deviceType: AVCaptureDevice.DeviceType) {
        var title = ""
        switch deviceType {
            case .builtInUltraWideCamera:
                title = "0.5"
            case .builtInWideAngleCamera:
                title = "1.0"
            case .builtInTelephotoCamera:
                title = "3.0"
            default:
                title = "1.0" // Default to wide angle
        }
        angleLensButton.setTitle(title, for: .normal)
    }
    // MARK: - Update All Buttons Configuration
    private func updateButtons(photoTaken: Bool) {
        captureButton.isHidden = photoTaken
        closeCameraButton.isHidden = photoTaken
        sendPhotoButton.isHidden = !photoTaken
        retakePhotoButton.isHidden = !photoTaken

        if photoTaken {
            view.bringSubviewToFront(sendPhotoButton)
            view.bringSubviewToFront(retakePhotoButton)
        } else {
            view.sendSubviewToBack(sendPhotoButton)
            view.sendSubviewToBack(retakePhotoButton)
        }

    }
    // MARK: - Show Taken Image
    private func showTakenPhotoImageView() {
        view.addSubview(capturedImageView)
        capturedImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension CustomCameraViewController: AVCapturePhotoCaptureDelegate {
    // MARK: - Photo Taken
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(), let capturedImage = UIImage(data: imageData) {
            print("Image captured successfully!")

            capturedImageView.image = capturedImage
            showTakenPhotoImageView()
            updateButtons(photoTaken: true)
        } else {
            if let error = error {
                print("Error capturing photo: \(error.localizedDescription)")
            } else {
                print("Unable to capture photo.")
            }
        }
    }
}

extension CustomCameraViewController: Alertable {}

class FocusIndicatorImageView: UIImageView { }
