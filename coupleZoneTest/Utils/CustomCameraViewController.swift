//
//  CustomCameraViewController.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 12.11.2023.
//

import UIKit
import AVFoundation

class CustomCameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private let borderLayer = CALayer()
    private let captureButton = UIButton(type: .system)
    private var capturedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCamera()
        setupBorderOverlay()
        setupCaptureButton()
    }

    // MARK: - Camera Setup

    private func setupCamera() {
        // Create and configure the capture session
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo

        // Set up the capture device
        guard let captureDevice = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: captureDevice) else {
            return
        }

        // Add the input to the session
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }

        // Configure the photo output
        let photoOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }

        // Ensure high-resolution capture is enabled
        photoOutput.isHighResolutionCaptureEnabled = true

        // Set up the preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)

        // Start the capture session on a background thread
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }

    // MARK: - Overlay Setup

    private func setupBorderOverlay() {
        // Create a border layer
        let borderSize: CGFloat = 400.0
        borderLayer.frame = CGRect(
            x: (view.bounds.width - borderSize) / 2,
            y: (view.bounds.height - borderSize) / 2,
            width: borderSize,
            height: borderSize
        )
        borderLayer.borderColor = UIColor.red.cgColor
        borderLayer.borderWidth = 2.0
        view.layer.addSublayer(borderLayer)
    }

    // MARK: - Capture Button Setup

    private func setupCaptureButton() {
        // Create and configure the capture button
        let buttonSize: CGFloat = 60.0
        captureButton.setImage(UIImage(systemName: "camera.circle.fill"), for: .normal)
        captureButton.tintColor = .white
        captureButton.backgroundColor = .systemBlue
        captureButton.layer.cornerRadius = buttonSize / 2
        captureButton.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)
        view.addSubview(captureButton)
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            captureButton.widthAnchor.constraint(equalToConstant: buttonSize),
            captureButton.heightAnchor.constraint(equalToConstant: buttonSize)
        ])
    }

    // MARK: - Capture Button Action

    @objc private func captureButtonTapped() {
        // Create photo settings
        let photoSettings = AVCapturePhotoSettings()

        // Capture a photo with the specified settings
        if let photoOutput = captureSession.outputs.first as? AVCapturePhotoOutput {
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }

    // MARK: - Photo Capture Delegate Methods

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(), let capturedImage = UIImage(data: imageData) {
            // Handle the captured image
            print("Image captured successfully!")
            self.capturedImage = capturedImage

            // Display the captured image
            let imageView = UIImageView(image: capturedImage)
            imageView.contentMode = .scaleAspectFit
            view.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
                imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                imageView.bottomAnchor.constraint(equalTo: captureButton.topAnchor, constant: -20)
            ])

            showRecaptureAndEditingOptions()
        } else {
            if let error = error {
                print("Error capturing photo: \(error.localizedDescription)")
            } else {
                print("Unable to capture photo.")
            }
        }
    }

    // MARK: - Recapture and Editing Options

    private func showRecaptureAndEditingOptions() {
        // Show recapture and editing options
        let recaptureButton = UIButton(type: .system)
        recaptureButton.setTitle("Recapture", for: .normal)
        recaptureButton.addTarget(self, action: #selector(recaptureButtonTapped), for: .touchUpInside)
        view.addSubview(recaptureButton)
        recaptureButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recaptureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recaptureButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20)
        ])

        let editButton = UIButton(type: .system)
        editButton.setTitle("Edit", for: .normal)
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        view.addSubview(editButton)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            editButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            editButton.topAnchor.constraint(equalTo: recaptureButton.bottomAnchor, constant: 20)
        ])
    }

    // MARK: - Recapture Button Action

    @objc private func recaptureButtonTapped() {
        // Restart the camera session
        self.captureSession.startRunning()

        // Remove the captured image view
        for subview in self.view.subviews {
            if subview is UIImageView {
                subview.removeFromSuperview()
            }
        }

        // Remove the recapture and editing options
        for subview in self.view.subviews {
            if subview is UIButton {
                subview.removeFromSuperview()
            }
        }
    }

    // MARK: - Edit Button Action

    @objc private func editButtonTapped() {
        // Check if an image is captured
        guard let capturedImage = capturedImage else {
            return
        }

        // Display the captured image for editing
        let imageView = UIImageView(image: capturedImage)
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageView.bottomAnchor.constraint(equalTo: captureButton.topAnchor, constant: -20)
        ])
    }
}

