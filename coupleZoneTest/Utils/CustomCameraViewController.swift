//
//  CustomCameraViewController.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 12.11.2023.
//

import UIKit
import AVFoundation
import SnapKit

class CustomCameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    // MARK: - Private Properties
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private let borderLayer = CALayer()
    private let captureButton = UIButton(type: .system)
    private let switchCameraButton = UIButton(type: .system)
    private let closeCameraButton = UIButton(type: .system)
    private let angleLensButton = UIButton(type: .system)
    private var capturedImage: UIImage?
    private var currentCamera: AVCaptureDevice?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupButtons()
    }

    // MARK: - Setup Camera
    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo

        guard let captureDevice = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: captureDevice) else {
            return
        }

        currentCamera = captureDevice

        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }

        let photoOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }

        photoOutput.isHighResolutionCaptureEnabled = true

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)

        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }

    // MARK: - Setup Buttons
    private func setupButtons() {
        setupCaptureButton()
        setupSwitchCameraButton()
        setupCloseCameraButton()
        setupAngleLensButton()
        switchCameraButtonTapped()
    }

    private func setupCaptureButton() {
        let buttonSize: CGFloat = 60.0
        captureButton.setImage(UIImage(systemName: "circle"), for: .normal)
        captureButton.imageView?.contentMode = .scaleAspectFill
        captureButton.tintColor = .white
        captureButton.backgroundColor = .LilacClouds.lilac1
        captureButton.round(corners: .allCorners, radius: buttonSize/2)
        captureButton.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)
        view.addSubview(captureButton)
        captureButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.size.equalTo(buttonSize)
        }
    }

    private func setupSwitchCameraButton() {
        let buttonSize: CGFloat = 40.0
        switchCameraButton.setImage(UIImage(systemName: "arrow.triangle.2.circlepath"), for: .normal)
        switchCameraButton.tintColor = .white
        switchCameraButton.backgroundColor = .LilacClouds.lilac1
        switchCameraButton.layer.cornerRadius = buttonSize / 2
        switchCameraButton.addTarget(self, action: #selector(switchCameraButtonTapped), for: .touchUpInside)
        view.addSubview(switchCameraButton)
        switchCameraButton.snp.makeConstraints { make in
            make.centerY.equalTo(captureButton.snp.centerY)
            make.right.equalTo(-20)
            make.size.equalTo(buttonSize)
        }
    }

    private func setupCloseCameraButton() {
        let buttonSize: CGFloat = 30.0
        closeCameraButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeCameraButton.tintColor = .white
        closeCameraButton.backgroundColor = .LilacClouds.lilac1
        closeCameraButton.layer.cornerRadius = buttonSize / 2
        closeCameraButton.addTarget(self, action: #selector(closeCameraButtonTapped), for: .touchUpInside)
        view.addSubview(closeCameraButton)
        closeCameraButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.equalTo(20)
            make.size.equalTo(buttonSize)
        }
    }
    private func setupAngleLensButton() {
        let buttonSize: CGFloat = 30.0
        angleLensButton.setTitle("1.0", for: .normal)
        angleLensButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
//        angleLensButton.setImage(UIImage(systemName: "arrow.up.backward.and.arrow.down.forward.circle"), for: .normal)
        angleLensButton.tintColor = .white
        angleLensButton.backgroundColor = .LilacClouds.lilac1
        angleLensButton.layer.cornerRadius = buttonSize / 2
        angleLensButton.addTarget(self, action: #selector(switchToWideAngleLens), for: .touchUpInside)
        view.addSubview(angleLensButton)
        angleLensButton.snp.makeConstraints { make in
            make.bottom.equalTo(captureButton.snp.top).offset(-20)
            make.centerX.equalToSuperview()
            make.size.equalTo(buttonSize)
        }
        updateLensButtonImage(for: .builtInWideAngleCamera)
    }

    // MARK: - Button Actions
    @objc private func closeCameraButtonTapped() {
        self.dismiss(animated: true)
    }

    @objc private func captureButtonTapped() {
        if let photoOutput = captureSession.outputs.first as? AVCapturePhotoOutput {
            let photoSettings = AVCapturePhotoSettings()
            photoSettings.isAutoStillImageStabilizationEnabled = true
            photoSettings.isHighResolutionPhotoEnabled = true
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }

    @objc private func switchCameraButtonTapped() {
        guard let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput else {
            return
        }

        let currentPosition = currentInput.device.position
        let newPosition: AVCaptureDevice.Position = (currentPosition == .back) ? .front : .back
        angleLensButton.isHidden = newPosition == .front

        // Find an available camera with the new position
        if let newCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition) {
            // Begin configuration changes
            captureSession.beginConfiguration()

            // Remove the current input
            captureSession.removeInput(currentInput)

            do {
                let newInput = try AVCaptureDeviceInput(device: newCamera)

                // Add the new input to the session
                if captureSession.canAddInput(newInput) {
                    captureSession.addInput(newInput)
                }

                // Configure mirroring based on the new camera position
                for output in captureSession.outputs {
                    guard let videoOutput = output as? AVCaptureVideoDataOutput,
                          let connection = videoOutput.connection(with: .video) else { continue }

                    if connection.isVideoMirroringSupported {
                        connection.automaticallyAdjustsVideoMirroring = false
                        connection.isVideoMirrored = (newPosition == .front)
                    }
                }

                // Configure photo output mirroring for front camera
                if let photoOutput = captureSession.outputs.first as? AVCapturePhotoOutput {
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
            captureSession.commitConfiguration()
        }
    }

    @objc private func switchToWideAngleLens() {
        guard let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput else {
            return
        }

        let lensTypes: [AVCaptureDevice.DeviceType] = [.builtInUltraWideCamera, .builtInWideAngleCamera, .builtInTelephotoCamera]
        let currentDeviceType = currentInput.device.deviceType

        // Find the index of the current lens
        if let currentIndex = lensTypes.firstIndex(of: currentDeviceType) {
            let nextIndex = (currentIndex + 1) % lensTypes.count
            let nextDeviceType = lensTypes[nextIndex]

            if let newCamera = AVCaptureDevice.default(nextDeviceType, for: .video, position: currentInput.device.position) {
                captureSession.beginConfiguration()
                captureSession.removeInput(currentInput)

                do {
                    let newInput = try AVCaptureDeviceInput(device: newCamera)

                    if captureSession.canAddInput(newInput) {
                        captureSession.addInput(newInput)
                    }

                    for output in captureSession.outputs {
                        guard let videoOutput = output as? AVCaptureVideoDataOutput,
                              let connection = videoOutput.connection(with: .video) else { continue }

                        if connection.isVideoMirroringSupported {
                            connection.automaticallyAdjustsVideoMirroring = false
                            connection.isVideoMirrored = (newCamera.position == .front)
                        }
                    }

                    if let photoOutput = captureSession.outputs.first as? AVCapturePhotoOutput {
                        if let connection = photoOutput.connection(with: .video),
                           connection.isVideoMirroringSupported {
                            connection.automaticallyAdjustsVideoMirroring = false
                            connection.isVideoMirrored = (newCamera.position == .front)
                        }
                    }
                } catch {
                    print("Error creating AVCaptureDeviceInput: \(error.localizedDescription)")
                }

                captureSession.commitConfiguration()
                updateLensButtonImage(for: nextDeviceType)
            }
        }
    }
    private func updateLensButtonImage(for deviceType: AVCaptureDevice.DeviceType) {
        var imageName = ""
        var title = ""

        switch deviceType {
            case .builtInUltraWideCamera:
                imageName = "05.circle"
            case .builtInWideAngleCamera:
                imageName = "1.circle"
            case .builtInTelephotoCamera:
                imageName = "3.circle"
            default:
                imageName = "1.circle" // Default to wide angle
        }
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

//        angleLensButton.setImage(UIImage(systemName: imageName), for: .normal)
        angleLensButton.setTitle(title, for: .normal)
        // Update the button's appearance as needed (color, size, etc.)
    }


    // MARK: - Photo Taken
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(), let capturedImage = UIImage(data: imageData) {
            print("Image captured successfully!")

            let imageView = UIImageView()
            imageView.image = capturedImage
            imageView.contentMode = .scaleAspectFit
            view.addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.top.equalTo(closeCameraButton.snp.bottom)
                make.leading.trailing.equalToSuperview()
                make.bottom.equalTo(captureButton.snp.top)
            }
        } else {
            if let error = error {
                print("Error capturing photo: \(error.localizedDescription)")
            } else {
                print("Unable to capture photo.")
            }
        }
    }
}
