//
//  SettingsViewController.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 18.10.2023.
//

import UIKit
import SnapKit
import OneSignalFramework

class SettingsViewController: UIViewController {

    // MARK: - UI Elements
    private lazy var homeIDLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
        button.addTarget(self, action: #selector(shareButtonAction), for: .touchUpInside)
        button.tintColor = .LilacClouds.lilac1
        return button
    }()
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    private lazy var changeUsernameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "pencil"), for: .normal)
        button.tintColor = .LilacClouds.lilac1
        button.addTarget(self, action: #selector(changeUsernameButtonAction), for: .touchUpInside)
        return button
    }()
    private lazy var anniversaryLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    private lazy var changeAnniversaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "clock"), for: .normal)
        button.tintColor = .LilacClouds.lilac1
        button.addTarget(self, action: #selector(changeAnniversaryButtonAction), for: .touchUpInside)
        return button
    }()

    // MARK: - Private Properties
    private var homeIDString = ""

    // MARK: - Lifecycle
    override func loadView() {
        super.loadView()
        setup()
        layout()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Settings didload")
        addJoinHomeButtonIfNeeded()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUsernameLabel()
        setHomeIDLabel()
        setAnniversaryLabel()
        print("Settings willappear")
    }

    // MARK: - Setup
    private func setup () {
        view.backgroundColor = .monkeyBlue
        view.addSubview(usernameLabel)
        view.addSubview(homeIDLabel)
        view.addSubview(shareButton)
        view.addSubview(changeUsernameButton)
        view.addSubview(anniversaryLabel)
        view.addSubview(changeAnniversaryButton)
    }

    private func layout() {
        homeIDLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.equalTo(10)
            make.trailing.equalTo(shareButton.snp.leading)
        }
        shareButton.snp.makeConstraints { make in
            make.centerY.equalTo(homeIDLabel.snp.centerY)
            make.trailing.equalTo(-20)
            make.size.equalTo(20)
        }
        usernameLabel.snp.makeConstraints { make in
            make.top.equalTo(homeIDLabel.snp.bottom).offset(20)
            make.leading.equalTo(10)
            make.trailing.equalTo(changeUsernameButton.snp.leading).offset(-5)
        }
        changeUsernameButton.snp.makeConstraints { make in
            make.centerY.equalTo(usernameLabel.snp.centerY)
            make.trailing.equalTo(-20)
            make.size.equalTo(20)
        }
        anniversaryLabel.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.snp.bottom).offset(20)
            make.leading.equalTo(10)
            make.trailing.equalTo(changeUsernameButton.snp.leading).offset(-5)
        }
        changeAnniversaryButton.snp.makeConstraints { make in
            make.centerY.equalTo(anniversaryLabel.snp.centerY)
            make.trailing.equalTo(-20)
            make.size.equalTo(20)
        }
    }

    // MARK: - Actions
    @objc private func changeUsernameButtonAction() {
        displayAlertWithTextfield(title: "Change Username", message: "Please enter your new username.", okButtonText: "That's it", cancelButtonText: "Nevermind", placeholder:  "Username: \(AppGlobal.shared.username ?? "")") { username in
            LottieHUD.shared.show()
            self.changeUsername(with: username) {
                NotificationCenter.default.post(name: .usernameChanged, object: nil)
                self.setUsernameLabel()
                LottieHUD.shared.dismiss()
            }
        }
    }
    @objc private func shareButtonAction() {
        let pasteboard = UIPasteboard.general
        pasteboard.string = homeIDString
        displaySimpleAlert(title: "Copied to clipboard!", message: "Just send your home ID to your partner! ", okButtonText: "OK", completion: nil)
    }
    @objc private func changeAnniversaryButtonAction() {
        displayAlertWithTextfield(title: "Change Anniversary?", message: "Please type in \"DD.MM.YYYY\" format.", okButtonText: "Change", cancelButtonText: "Cancel", placeholder: "(e.g 15.01.1999)") { dateString in
            self.changeAnniversaryDate(with: dateString) {
                NotificationCenter.default.post(name: .anniversaryChanged, object: nil)
                self.setAnniversaryLabel()
            }
        }
    }

    // MARK: - Private Methods
    private func changeUsername(with username: String, completion: @escaping () -> Void) {
        Task {
            guard let userEmail = AppGlobal.shared.user?.email else { return }
            try await SensitiveData.supabase.database.from("users").update(values: ["username": username]).eq(column: "email", value: userEmail).execute()
            AppGlobal.shared.username = username
            completion()
        }
    }
    private func setUsernameLabel() {
        let title = NSMutableAttributedString(string: "Username: ", attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .semibold)])
        let username = NSMutableAttributedString(string: AppGlobal.shared.username ?? "Anonymous", attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .regular)])
        title.append(username)
        usernameLabel.attributedText = title
    }
    private func setHomeIDLabel() {
        Task {
            LottieHUD.shared.show()
            let idString = await getHomeID()
            let homeIDTitle = NSMutableAttributedString(string: "Home ID: ", attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .semibold)])
            let homeIDValue = NSMutableAttributedString(string: idString, attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .regular)])
            homeIDTitle.append(homeIDValue)
            homeIDLabel.attributedText = homeIDTitle
            LottieHUD.shared.dismiss()
        }
    }
    private func setAnniversaryLabel() {
        Task {
            LottieHUD.shared.show()
            let anniversaryDateString = await getAnniversaryText()
            let anniversaryTitle = NSMutableAttributedString(string: "Together Since: ", attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .semibold)])
            let anniversaryValue = NSMutableAttributedString(string: anniversaryDateString, attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .regular)])
            anniversaryTitle.append(anniversaryValue)
            anniversaryLabel.attributedText = anniversaryTitle
            LottieHUD.shared.dismiss()
        }
    }
    private func addJoinHomeButtonIfNeeded() {
        Task {
            LottieHUD.shared.show()
            let homeID = await getHomeID()
            let homeDict = try await SensitiveData.supabase.database.from("homes").select(columns: "*", head: false).eq(column: "id", value: homeID).execute().underlyingResponse.data.convertDataToString().convertStringToDictionary()
            if homeDict == nil {
                let button = UIButton(type: .system)
                button.setTitle("Connect your home", for: .normal)
                button.setTitleColor(.LilacClouds.lilac1, for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
                button.addBorder(borderColor: .LilacClouds.lilac1, borderWidth: 1)
                button.round(corners: .allCorners, radius: 4)
                view.addSubview(button)
                button.snp.makeConstraints { make in
                    make.top.equalTo(usernameLabel.snp.bottom).offset(10)
                    make.leading.equalTo(10)
                    make.height.equalTo(20)
                    make.trailing.equalTo(-20)
                }
            }
        }
    }
    private func getHomeID() async -> String {
        do {
            guard let userID = AppGlobal.shared.user?.id else { return "" }
            let userDict = try await SensitiveData.supabase.database.from("users").select(columns: "*", head: false).eq(column: "userID", value: userID).execute().underlyingResponse.data.convertDataToString().convertStringToDictionary()
            let idString = userDict?["homeID"] as? String ?? ""
            return idString
        } catch let error {
            LottieHUD.shared.dismiss()
            print(error.localizedDescription)
            return ""
        }
    }
    private func changeAnniversaryDate(with dateString: String, completion: @escaping () -> Void) {
        Task {
            LottieHUD.shared.show()
            let dateToPut = getFormattedDateForBackend(from: dateString)
            guard !dateToPut.isEmpty else {
                LottieHUD.shared.dismiss()
                displaySimpleAlert(title: "Error", message: "Try again.", okButtonText: "OK") {
                    self.changeAnniversaryButtonAction()
                }
                return
            }
            let homeID = await self.getHomeID()
            let updateTable = SensitiveData.supabase.database.from("homes").update(values: ["anniversary_date": dateToPut]).eq(column: "id", value: homeID)
            try await updateTable.execute()
            print("Change Anniversary Date Success")
            LottieHUD.shared.dismiss()
            completion()
        }
    }
    private func getFormattedDateForBackend(from dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"

        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            let convertedDateString = dateFormatter.string(from: date)
            print(convertedDateString)

            let calendar = Calendar.current
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())

            if date >= (tomorrow ?? Date()) {
                print("Date is in the future")
                return ""
            }
            return convertedDateString
        } else {
            print("Invalid date string format")
            return ""
        }
    }
    private func getAnniversaryText() async -> String {
        do {
            let homeID = await getHomeID()
            let anniversaryDict = try await SensitiveData.supabase.database.from("homes").select(columns: "anniversary_date", head: false).eq(column: "id", value: homeID).execute().underlyingResponse.data.convertDataToString().convertStringToDictionary()
            let anniversaryDateString = anniversaryDict?["anniversary_date"] as? String ?? ""
            let formattedDate = getFormattedDateForDisplay(from: anniversaryDateString)
            return formattedDate
        } catch let error {
            print(error.localizedDescription)
            return ""
        }
    }
    private func getFormattedDateForDisplay(from dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"

        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "dd.MM.yyyy"
            let convertedDateString = dateFormatter.string(from: date)
            return convertedDateString
        } else {
            print("Invalid date string format")
            return ""
        }
    }
}

// MARK: - Alertable
extension SettingsViewController: Alertable {}
