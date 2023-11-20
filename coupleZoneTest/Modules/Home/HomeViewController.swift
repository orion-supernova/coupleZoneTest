//
//  HomeViewController.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 18.10.2023.
//

import UIKit
import SnapKit
import SideMenu

@MainActor protocol HomeDisplayLogic: AnyObject {
    func display(_ model: HomeModels.FetchData.ViewModel, loadPhoto: Bool)
    func displayHomeNotExist()
    func displayError(with message: String)
    func displayImagePicker()
    func displaySuccessAfterPhotoUpload()
}

final class HomeViewController: UIViewController {

    // MARK: - UI Elements
    private lazy var welcomeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .LilacClouds.lilac2
        label.numberOfLines = 0
        return label
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle.fill")
        imageView.tintColor = .LilacClouds.lilac3
        imageView.contentMode = .scaleAspectFill
        imageView.round(corners: .allCorners, radius: 10)
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewAction))
        imageView.addGestureRecognizer(gestureRecognizer)
        return imageView
    }()

    private lazy var sendLoveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send Love", for: .normal)
        button.addTarget(self, action: #selector(sendLoveButtonAction), for: .touchUpInside)
        button.tintColor = .LilacClouds.lilac3
        button.addBorder(borderColor: .LilacClouds.lilac4, borderWidth: 2)
        button.round(corners: .allCorners, radius: 3)
        return button
    }()
    
    // MARK: Private Properties
    private let router: HomeRouter
    private let interactor: HomeBusinessLogic
    private var sideMenu: SideMenuNavigationController?

    // MARK: Initializers
    init(interactor: HomeBusinessLogic, router: HomeRouter) {
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
        view.backgroundColor = UIColor.LilacClouds.lilac0
        setup()
        layout()
        setupSideMenu()
        configureNavigationBar()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData(request: .init(fetchPhoto: true))
    }
    override func viewWillAppear(_ animated: Bool) {
        fetchData(request: .init(fetchPhoto: false))
    }

    // MARK: - Setup
    @MainActor private func setup() {
        view.addSubview(welcomeLabel)
        view.addSubview(imageView)
        view.addSubview(sendLoveButton)
    }

    // MARK: - Layout
    @MainActor private func layout() {
        welcomeLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
        }
        imageView.snp.makeConstraints { make in
            make.top.equalTo(welcomeLabel.snp.bottom).offset(20)
            make.size.equalTo(view.snp.width).multipliedBy(0.7)
            make.centerX.equalToSuperview()
        }
        sendLoveButton.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(30)
            make.leading.equalTo(imageView.snp.leading)
            make.trailing.equalTo(imageView.snp.trailing)
            make.height.equalTo(44)
        }
    }

    // MARK: - Private Methods
    private func configureNavigationBar() {
        let settingsButton = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .done, target: self, action: #selector(settingsButtonAction))
        navigationItem.rightBarButtonItems = [settingsButton]
        navigationItem.rightBarButtonItem?.tintColor = .LilacClouds.lilac3
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle"), style: .done, target: self, action: #selector(profileMenuButtonAction))
        navigationItem.leftBarButtonItem?.tintColor = .LilacClouds.lilac3

        let titleViewLabel : UILabel = {
            let label = UILabel()
            label.text = "Lover Board"
            label.textColor = .LilacClouds.lilac4
            label.font = .systemFont(ofSize: 20, weight: .bold)
            return label
        }()
        navigationItem.titleView = titleViewLabel
    }

    private func setupSideMenu() {
        sideMenu = SideMenuNavigationController(rootViewController: SettingsViewController())
        sideMenu?.leftSide = true
        sideMenu?.setNavigationBarHidden(true, animated: false)

        SideMenuManager.default.leftMenuNavigationController = sideMenu
        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
    }

    private func fetchData(request: HomeModels.FetchData.Request) {
        LottieHUD.shared.show()
        interactor.fetchData(request)
    }

    // MARK: - Actions
    @objc private func sendLoveButtonAction() {
        displaySimpleAlert(title: "Yes", message: "Love sent!", okButtonText: "OK") {
            //
        }
    }
    @objc private func imageViewAction() {
        displayAlertTwoButtons(title: "Change Photo", message: "Do you want to change the photo?", firstButtonText: "Yes", firstButtonStyle: .default, seconButtonText: "Nope", secondButtonStyle: .cancel) {
            self.interactor.changePhotoTapped()
        } secondButtonCompletion: {
            //
        }
    }
    @objc private func settingsButtonAction() {
//        let viewController = SettingsViewController()
//        present(viewController, animated: true)
        displayAlertTwoButtons(title: "Sign Out?", message: "Dou you want to signout?", firstButtonText: "Yeap", firstButtonStyle: .destructive, seconButtonText: "Nope, I thought it was settings.", secondButtonStyle: .default) {
            LottieHUD.shared.showWithoutDelay()
            AuthManager.shared.signOut { result in
                LottieHUD.shared.dismiss()
                switch result {
                    case .success(_):
                        DispatchQueue.main.async {
                            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let sceneDelegate = windowScene.delegate as? SceneDelegate else { return }
                            sceneDelegate.navigateFromAuth()
                        }
                    case .failure(let error):
                        self.displaySimpleAlert(title: "Error", message: error.localizedDescription, okButtonText: "OK")
                }
            }
        } secondButtonCompletion: {
            //
        }
    }
    @objc private func profileMenuButtonAction() {
        guard let sideMenu else { return }
        self.present(sideMenu, animated: true)
    }
}

// MARK: - Alertable
extension HomeViewController: Alertable {}


// MARK: - Display Logic
extension HomeViewController: HomeDisplayLogic {
    func display(_ model: HomeModels.FetchData.ViewModel, loadPhoto: Bool) {
        let displayModel = model.displayModel
        self.welcomeLabel.attributedText = getAttributedWelcomeMessage(username: displayModel.username, partnerName: displayModel.partnerUsername, numberOfDays: displayModel.numberOfDays, numberOfDaysInOrder: displayModel.numberOfDaysInOrder)
        if loadPhoto {
            self.imageView.setImage(urlString: displayModel.imageURLString) {
                LottieHUD.shared.dismiss()
            }
        } else {
            LottieHUD.shared.dismiss()
        }
    }
    func displayError(with message: String) {
        LottieHUD.shared.dismiss()
        displaySimpleAlert(title: "Error", message: message, okButtonText: "OK")
    }
    func displayHomeNotExist() {
        LottieHUD.shared.dismiss()
        let viewController = CreateOrJoinRoomViewController()
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true)
    }
    func displayImagePicker() {
        LottieHUD.shared.showWithoutDelay()
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true) {
            LottieHUD.shared.dismiss()
        }
    }
    func displaySuccessAfterPhotoUpload() {
        interactor.fetchData(.init(fetchPhoto: true))
        displaySimpleAlert(title: "Successs", message: "Photo changed successfully!", okButtonText: "OK")
    }
}

// MARK: - Image Picker
extension HomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var image = UIImage(named: "person")
        if let editedImage = info[.editedImage] as? UIImage {
            image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            image = originalImage
        }
        picker.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.interactor.uploadPhoto(.init(image: image!))
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - Attributed Welcome Message
extension HomeViewController {
    private func getAttributedWelcomeMessage(username: String, partnerName: String, numberOfDays: Int, numberOfDaysInOrder: [Int]) -> NSAttributedString {
        let welcomeIntro = NSMutableAttributedString(string: "Welcome \(username),\n", attributes: [.font: UIFont.systemFont(ofSize: 17, weight: .semibold)])
        let two = NSMutableAttributedString(string: "You've been together with this weirdo\n", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .regular)])
        let three = NSMutableAttributedString(string: "\(partnerName) ", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .semibold)])
        let four = NSMutableAttributedString(string: "for the past ", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .regular)])
        let five = NSMutableAttributedString(string: "\(numberOfDays)", attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .bold)])
        let six = NSMutableAttributedString(string: " days.", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .regular)])
        let seven = NSMutableAttributedString(string: "\nWhich is ", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .regular)])
        let eight = NSMutableAttributedString(string: "\(String(describing: numberOfDaysInOrder[safeIndex: 0] ?? 0)) \(numberOfDaysInOrder[safeIndex: 0] == 1 ? "year" : "years"), \(numberOfDaysInOrder[safeIndex: 1] ?? 0) \(numberOfDaysInOrder[safeIndex: 1] == 1 ? "month" : "months"), \(numberOfDaysInOrder[safeIndex: 2] ?? 0) \(numberOfDaysInOrder[safeIndex: 2] == 1 ? "day" : "days")", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .bold)])
        let nine = NSMutableAttributedString(string: "", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .regular)])
        welcomeIntro.append(two)
        if !partnerName.isEmpty {
            welcomeIntro.append(three)
        }
        welcomeIntro.append(four)
        welcomeIntro.append(five)
        welcomeIntro.append(six)
        welcomeIntro.append(seven)
        welcomeIntro.append(eight)
        welcomeIntro.append(nine)
        return welcomeIntro
    }
}

