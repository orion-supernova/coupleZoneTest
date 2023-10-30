//
//  LoginViewController.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 27.10.2023.
//

import UIKit
import AuthenticationServices
import SnapKit
import RiveRuntime

class LoginViewController: UIViewController {

    // MARK: - UI Elements
    private lazy var animationBackgroundView: RiveView = {
        let view = RiveView()
        riveViewModel.setView(view)
        riveViewModel.fit = .fitHeight
        return view
    }()

    private let logoImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.image = UIImage(named: "logoBlackWhite")
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()

    private lazy var loginLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "Login to connect with your partner!"
        label.textColor = .black //.LilacClouds.lilac2
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()

    private lazy var loginButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton()
        button.addTarget(self, action: #selector(loginButtonAction), for: .touchUpInside)
        return button
    }()

    // MARK: - Private Properties
    let riveViewModel = RiveViewModel(fileName: "coupleKissing")

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .LilacClouds.lilac0
        view.backgroundColor = UIColor(hexString: "121939")
        setup()
        layout()
    }

    // MARK: - Setup
    private func setup() {
        view.addSubview(animationBackgroundView)
        view.addSubview(logoImageView)
        view.addSubview(loginLabel)
        view.addSubview(loginButton)
    }

    private func layout() {
        animationBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        //        animationBackgroundView.frame = CG
        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(50)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(300)
        }
        loginLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            //            make.top.equalTo(logoImageView.snp.bottom).offset(20)
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.height.greaterThanOrEqualTo(50)
        }
        loginButton.snp.makeConstraints { make in
            //            make.top.equalTo(loginLabel.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalTo(200)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-70)
        }
    }

    // MARK: - Actions
    @objc private func loginButtonAction() {
        AuthManager.shared.startSignInWithAppleFlow { result in
            switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let sceneDelegate = windowScene.delegate as? SceneDelegate else { return }
                        sceneDelegate.navigateFromAuth()
                    }
                case .failure(let error):
                    print("DEBUG: -----", error)
                    self.displaySimpleAlert(title: "Error", message: error.localizedDescription, okButtonText: "OK") {
                    }
            }
        }
    }
}

extension LoginViewController: Alertable {}
