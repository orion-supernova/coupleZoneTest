//
//  LastPhotoViewController.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 12.11.2023.
//

import UIKit
import SnapKit

class LastPhotoViewController: UIViewController {

    // MARK: - UI Elements
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewAction))
        imageView.addGestureRecognizer(gestureRecognizer)
        return imageView
    }()

    private lazy var downloadButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Download", attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .bold), .foregroundColor: UIColor.LilacClouds.lilac4])
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(downloadButtonAction), for: .touchUpInside)
        button.addBorder(borderColor: .LilacClouds.lilac4, borderWidth: 1)
        button.round(corners: .allCorners, radius: 4)
        return button
    }()

    // MARK: Initializers
    init(photo: UIImage) {
        super.init(nibName: nil, bundle: nil)
        imageView.image = photo
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: - Lifecycle
    override func loadView() {
        super.loadView()
        setup()
        layout()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Setup
    private func setup() {
        view.backgroundColor = .systemPink
        view.addSubview(imageView)
        view.addSubview(downloadButton)
    }

    private func layout() {
        imageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.equalTo(10)
            make.trailing.equalTo(-10)
            make.bottom.equalTo(downloadButton.snp.top).offset(-20)
        }
        downloadButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-200)
            make.leading.equalTo(10)
            make.trailing.equalTo(-10)
            make.height.equalTo(40)
        }
    }

    // MARK: - Actions
    @objc private func imageViewAction() {

    }
    @objc private func downloadButtonAction() {
        if let image = imageView.image {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // Handle error
            print("Error saving image to photo library: \(error.localizedDescription)")
            displaySimpleAlert(title: "Error!", message: error.localizedDescription, okButtonText: "OK")
        } else {
            // Image saved successfully
            print("Image saved to photo library")
            displaySimpleAlert(title: "Success!", message: "Check your photo library!", okButtonText: "OK")
        }
    }
}

extension LastPhotoViewController: Alertable {}
