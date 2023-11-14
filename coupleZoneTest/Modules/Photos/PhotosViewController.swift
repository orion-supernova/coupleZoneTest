//
//  PhotosViewController.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 18.10.2023.
//

import UIKit

@MainActor protocol PhotosDisplayLogic: AnyObject {
    func display(_ model: PhotosModels.FetchData.ViewModel)
    func displayError(_ errorString: String)
    func displaySuccess()
}

class PhotosViewController: UIViewController {

    // MARK: - UI Elements
    private lazy var lastPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "bicycle")
        imageView.tintColor = .monkeyBlue
        imageView.contentMode = .scaleAspectFill
        imageView.round(corners: .allCorners, radius: 10)
        imageView.addBorder(borderColor: .monkeyBlue, borderWidth: 2)
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(lastPhotoImageViewAction))
        imageView.addGestureRecognizer(gestureRecognizer)
        imageView.backgroundColor = .systemPink
        return imageView
    }()

    private lazy var timelineTableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PhotosTableViewCell.self, forCellReuseIdentifier: PhotosTableViewCell.cellIdentifier)
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
//        tableView.round(corners: .allCorners, radius: 4)
        tableView.showsVerticalScrollIndicator = true
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemPink
        return tableView
    }()

    private lazy var streakLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .LilacClouds.lilac4
        label.textAlignment = .center
        label.round(corners: .allCorners, radius: 4)
        label.addBorder(borderColor: .LilacClouds.lilac4, borderWidth: 2)
        return label
    }()

    // MARK: Private Properties
    private let router: PhotosRouter
    private let interactor: PhotosBusinessLogic
    private var items = [PhotosModels.FetchData.ViewModel.DisplayableModel]()

    // MARK: Initializers
    init(interactor: PhotosBusinessLogic, router: PhotosRouter) {
        self.interactor = interactor
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: - Lifecycle
    override func loadView() {
        super.loadView()
        setup()
        layout()
        configureNavigationBar()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        LottieHUD.shared.show()
        interactor.fetchData(.init())
    }
    // MARK: - Setup
    private func setup() {
        view.backgroundColor = .systemPink
        view.addSubview(timelineTableView)
        view.addSubview(lastPhotoImageView)
        view.addSubview(streakLabel)
    }

    private func layout() {
        lastPhotoImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.equalTo(10)
            make.trailing.equalTo(-10)
            make.height.equalToSuperview().multipliedBy(0.4)
        }
        timelineTableView.snp.makeConstraints { make in
            make.top.equalTo(lastPhotoImageView.snp.bottom).offset(5)
            make.leading.equalTo(25)
            make.trailing.equalTo(-25)
            make.bottom.equalTo(streakLabel.snp.top).offset(-20)
        }
        streakLabel.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-25)
            make.leading.equalTo(40)
            make.trailing.equalTo(-40)
            make.height.equalTo(30)
        }
    }

    // MARK: - Private Methods
    @MainActor private func configureNavigationBar() {
        let sendPhotoButton = UIBarButtonItem(image: UIImage(systemName: "flame"), style: .done, target: self, action: #selector(sendPhotoButtonAction))
        navigationItem.rightBarButtonItems = [sendPhotoButton]
        navigationItem.rightBarButtonItem?.tintColor = .monkeyBlue

        let titleViewLabel : UILabel = {
            let label = UILabel()
            label.text = "Caution, Hot Area!"
            label.textColor = .LilacClouds.lilac4
            label.font = .systemFont(ofSize: 20, weight: .bold)
            return label
        }()
        navigationItem.titleView = titleViewLabel
    }
    @MainActor private func scrollToBottom() {
        let row = timelineTableView.numberOfRows(inSection: 0) - 1
        let indexPath = IndexPath(row: row, section: 0)
        timelineTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    @MainActor private func presentImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.cameraCaptureMode = .photo
        imagePicker.cameraDevice = .front
        imagePicker.cameraFlashMode = .off
        imagePicker.allowsEditing = false
        imagePicker.delegate = self

        // Flip the photo horizontally to correct mirroring
//        imagePicker.cameraViewTransform = CGAffineTransform(scaleX: -1.0, y: 1.0)

        // Allow more freedom in cropping
        imagePicker.showsCameraControls = true
        imagePicker.isNavigationBarHidden = false
        imagePicker.isToolbarHidden = false
        present(imagePicker, animated: true)
    }

    // MARK: - Actions
    @objc private func sendPhotoButtonAction() {
        displayAlertTwoButtons(title: "Send Photo", message: "It's getting hot in here!", firstButtonText: "I changed my mind.", firstButtonStyle: .destructive, seconButtonText: "Take Photo!", secondButtonStyle: .default) {
            self.displaySimpleAlert(title: "Why?", message: ":(", okButtonText: "...") {
                //
            }
        } secondButtonCompletion: {
            self.presentImagePicker()
        }

    }
    @objc private func lastPhotoImageViewAction() {
        guard let image = lastPhotoImageView.image else { return }
        let viewController = LastPhotoViewController(photo: image)
        self.present(viewController, animated: true)
    }
}

// MARK: - Alertable
extension PhotosViewController: Alertable {}

// MARK: - Display Logic
extension PhotosViewController: PhotosDisplayLogic {
    func displayError(_ errorString: String) {
        DispatchQueue.main.async {
            self.displaySimpleAlert(title: "Error", message: errorString, okButtonText: "OK", completion: nil)
        }
    }
    func display(_ model: PhotosModels.FetchData.ViewModel) {
        self.items.removeAll()
        model.displayModels.forEach({ item in
            self.items.append(item)
        })
        let lastItem = model.displayModels.last
        DispatchQueue.main.async {
            self.streakLabel.text = "Streak \(model.displayModels.count)!"
            self.lastPhotoImageView.setImage(urlString: lastItem?.imageURLString) {
                LottieHUD.shared.dismiss()
            }
            self.timelineTableView.reloadData {
                self.scrollToBottom()
            }
        }
    }
    func displaySuccess() {
        DispatchQueue.main.async {
            self.displaySimpleAlert(title: "Success", message: "Olley!", okButtonText: "OK") {
                self.interactor.fetchData(.init())
            }
        }
    }
}

// MARK: - UITableView DataSource
extension PhotosViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PhotosTableViewCell.cellIdentifier, for: indexPath) as? PhotosTableViewCell else { return UITableViewCell () }
        let model = PhotosTableViewCell.DisplayableModel(imageURLString: self.items[indexPath.row].imageURLString, uploadTimeString: self.items[indexPath.row].uploadDate, usernameString: self.items[indexPath.row].usernameString)
        cell.configure(with: model)
        return cell
    }
}

// MARK: - UITableView Delegate
extension PhotosViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let urlString = self.items[indexPath.row].imageURLString
        let url = URL(string: urlString)
        self.lastPhotoImageView.setImage(url: url) {
            LottieHUD.shared.dismiss()
        }
    }
}

// MARK: - Image Picker
extension PhotosViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var image = UIImage(named: "person")
        if let editedImage = info[.editedImage] as? UIImage {
            // Upload the editedImage to the server
            // Call your upload function here
            // ...
            image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            // Upload the originalImage to the server
            // Call your upload function here
            // ...
            image = originalImage
        }
        // Dismiss the image picker
        picker.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.interactor.uploadPhoto(.init(image: image!))
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Handle cancellation
        picker.dismiss(animated: true) {
            self.displaySimpleAlert(title: "Why?", message: "Why did you cancel? Come on!", okButtonText: "...", completion: nil)
        }
    }
}
