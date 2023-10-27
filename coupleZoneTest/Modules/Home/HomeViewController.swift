//
//  HomeViewController.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 18.10.2023.
//

import UIKit
import SnapKit

@MainActor protocol HomeDisplayLogic: AnyObject {
    func display(_ model: HomeModels.FetchData.ViewModel)
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
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.LilacClouds.lilac0
        setup()
        layout()
        configureNavigationBar()
        fetchData()
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
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
        }
        imageView.snp.makeConstraints { make in
            make.top.equalTo(welcomeLabel.snp.bottom).offset(10)
            make.size.equalTo(view.snp.width).multipliedBy(0.7)
            make.centerX.equalToSuperview()
        }
        sendLoveButton.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(10)
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

        let titleViewLabel : UILabel = {
            let label = UILabel()
            label.text = "Lover Board"
            label.textColor = .LilacClouds.lilac4
            label.font = .systemFont(ofSize: 20, weight: .bold)
            return label
        }()
        navigationItem.titleView = titleViewLabel
    }
    
    private func fetchData() {
        interactor.fetchData(.init())
    }

    // MARK: - Actions
    @objc private func sendLoveButtonAction() {
        displaySimpleAlert(title: "Yes", message: "Love sent!", okButtonText: "OK") {
            //
        }
    }
    @objc private func imageViewAction() {
        displaySimpleAlert(title: "Yes", message: "ImageView Tapped", okButtonText: "OK") {
            //
        }
    }
    @objc private func settingsButtonAction() {
        let viewController = SettingsViewController()
        present(viewController, animated: true)
    }
}

// MARK: - Alertable
extension HomeViewController: Alertable {}

// MARK: - Display Logic
extension HomeViewController: HomeDisplayLogic {
    func display(_ model: HomeModels.FetchData.ViewModel) {
        let displayModel = model.displayModel
        self.imageView.setImage(urlString: displayModel.imageURLString)
        self.welcomeLabel.text = "Welcome \(displayModel.username),\nYou've been together with this weirdo(\(displayModel.partnerUsername)) for the past \(displayModel.numberOfDays) days."
    }
}

