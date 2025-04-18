//
//  ChatViewControllerNavigationView.swift
//  coupleZoneTest
//
//  Created by muratcankoc on 09/06/2024.
//

import UIKit
import SnapKit
import Supabase

extension ChatRoomViewController {

    final class NavigationView: UIView {

        // MARK: - UI Elements
        private lazy var containerView: UIView = {
            let view = UIView(frame: .zero)
            return view
        }()
        private lazy var topNotchView: UIView = {
            let view = UIView(frame: .zero)
            return view
        }()
        private lazy var contentView: UIView = {
            let view = UIView(frame: .zero)
            return view
        }()
        private lazy var blurView: UIVisualEffectView = {
            let effect = UIBlurEffect(style: .prominent)
            let blurView = UIVisualEffectView(effect: effect)
            return blurView
        }()

        private lazy var titleLabel: UILabel = {
            let label = UILabel(frame: .zero)
            label.text = "Luv Chat"
            label.font = .systemFont(ofSize: 18, weight: .medium)
            return label
        }()

        private lazy var partnerStatusLabel: UILabel = {
            let label = UILabel(frame: .zero)
            label.textColor = .secondaryLabel
            label.text = "Offline"
            label.font = .systemFont(ofSize: 12, weight: .regular)
            return label
        }()

        private lazy var profileImageView: UIImageView = {
            let imageView = UIImageView(frame: .zero)
            imageView.contentMode = .scaleAspectFill
            let gesture = UITapGestureRecognizer(target: self, action: #selector(profileImageViewAction))
            imageView.addGestureRecognizer(gesture)
            imageView.isUserInteractionEnabled = true
            return imageView
        }()

        // MARK: - Lifecycle
        init() {
            super.init(frame: .zero)
            setup()
            layout()
            Task {
                await fetchProfilePhoto()
            }
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: - Setup
        private func setup() {
            addSubview(containerView)
            containerView.addSubview(topNotchView)
            containerView.addSubview(blurView)
            containerView.addSubview(contentView)
            contentView.addSubview(titleLabel)
            contentView.addSubview(partnerStatusLabel)
            contentView.addSubview(profileImageView)
        }

        private func layout() {
            containerView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            topNotchView.snp.makeConstraints { make in
                make.top.horizontalEdges.equalToSuperview()
                make.bottom.equalTo(safeAreaLayoutGuide.snp.top)
            }
            contentView.snp.makeConstraints { make in
                make.top.equalTo(topNotchView.snp.bottom)
                make.horizontalEdges.bottom.equalToSuperview()
            }
            blurView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            titleLabel.snp.makeConstraints { make in
                make.top.equalTo(safeAreaLayoutGuide.snp.top)
                make.centerX.equalToSuperview()
                make.height.equalTo(20)
            }
            partnerStatusLabel.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom)
                make.bottom.equalTo(-5)
                make.width.greaterThanOrEqualTo(30)
                make.centerX.equalToSuperview()
            }
            profileImageView.snp.makeConstraints { make in
                make.left.equalTo(10)
                make.size.equalTo(30)
            }
        }
        // MARK: - Actions
        @objc private func profileImageViewAction() {
            DispatchQueue.main.async {
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let sceneDelegate = windowScene.delegate as? SceneDelegate else { return }
                sceneDelegate.navigateFromAuth(selectedIndex: 0)
            }
        }
        // MARK: - Public Methods
        func setOnlineStatus(_ status: String) {
            DispatchQueue.main.async {
                self.partnerStatusLabel.text = status
            }
        }
        // MARK: - Private Methods
        private func fetchProfilePhoto() async {
            do {
                let homeID = try await SensitiveData.supabase.from("users").select("homeID").eq("userID", value: AppGlobal.shared.user?.id.uuidString ?? "").execute().data.convertDataToString().convertStringToDictionary()?["homeID"] as? String ?? ""
                let profileImageURLString = try await SensitiveData.supabase.from("homes").select("imageURLString").eq("id", value: homeID).execute().data.convertDataToString().convertStringToDictionary()?["imageURLString"] as? String ?? ""
                DispatchQueue.main.async {
                    self.profileImageView.setImage(urlString: profileImageURLString, placeholder: nil)
//                    self.profileImageView.round(corners: .allCorners, radius: 12)
                    self.profileImageView.makeCircular()
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}
