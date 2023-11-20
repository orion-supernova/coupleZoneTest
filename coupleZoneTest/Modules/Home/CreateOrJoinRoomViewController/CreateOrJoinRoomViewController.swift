//
//  CreateOrJoinRoomViewController.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 19.11.2023.
//

import UIKit
import SnapKit

class CreateOrJoinRoomViewController: UIViewController {
    // MARK: - UI Elements
    private lazy var mainContentView: UIView = {
        let view = UIView()
        return view
    }()
    private lazy var welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to Couple Zone!\n"
        label.numberOfLines = 0
        label.textColor = .LilacClouds.lilac1
        return label
    }()
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Seems like you don't have any home right now. Would you like to create a new one or join an existing one?"
        label.numberOfLines = 0
        label.textColor = .LilacClouds.lilac1
        return label
    }()
    private lazy var createHomeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create a new home", for: .normal)
        button.setTitleColor(.LilacClouds.lilac1, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.addBorder(borderColor: .LilacClouds.lilac1, borderWidth: 1)
        button.round(corners: .allCorners, radius: 4)
        button.addTarget(self, action: #selector(createHomeButtonAction), for: .touchUpInside)
        return button
    }()
    private lazy var joinHomeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Join an existing one", for: .normal)
        button.setTitleColor(.LilacClouds.lilac1, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.addBorder(borderColor: .LilacClouds.lilac1, borderWidth: 1)
        button.round(corners: .allCorners, radius: 4)
        button.addTarget(self, action: #selector(joinHomeButtonAction), for: .touchUpInside)
        return button
    }()
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
        view.backgroundColor = .LilacClouds.lilac4
        view.addSubview(mainContentView)
        mainContentView.addSubview(welcomeLabel)
        mainContentView.addSubview(infoLabel)
        mainContentView.addSubview(createHomeButton)
        mainContentView.addSubview(joinHomeButton)
    }
    private func layout() {
        mainContentView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
        }
        welcomeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
        }
        infoLabel.snp.makeConstraints { make in
            make.top.equalTo(welcomeLabel.snp.bottom).offset(5)
            make.horizontalEdges.equalToSuperview()
        }
        createHomeButton.snp.makeConstraints { make in
            make.top.equalTo(infoLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(30)
        }
        joinHomeButton.snp.makeConstraints { make in
            make.top.equalTo(createHomeButton.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(30)
        }
    }
    // MARK: - Actions
    @objc private func createHomeButtonAction() {
        displayAlertTwoButtons(title: "Create", message: "Are you sure?", firstButtonText: "Yeap!", firstButtonStyle: .default, seconButtonText: "Let me think and come back.", secondButtonStyle: .cancel) {
            self.askForAnniversary()
        } secondButtonCompletion: {
            //
        }
    }
    @objc private func joinHomeButtonAction() {
        displayAlertWithTextfield(title: "Join", message: "Please enter the id of your home.", okButtonText: "Let's Go!", cancelButtonText: "F*ck It.", placeholder: "Your Home ID...") { homeID in
            Task {
                LottieHUD.shared.showWithoutDelay()
                await self.checkHomeData(with: homeID) { result in
                    switch result {
                        case .success(let homeID):
                            self.connectUserWithHome(homeID: homeID) { result in
                                switch result {
                                    case .success(let message):
                                        LottieHUD.shared.dismiss()
                                        self.displaySimpleAlert(title: "Success", message: message, okButtonText: "OK") {
                                            self.dismiss(animated: true) {
                                                NotificationCenter.default.post(name: .addUserToHomeSuccess, object: nil)
                                            }
                                        }
                                    case .failure(let error):
                                        LottieHUD.shared.dismiss()
                                        self.displaySimpleAlert(title: "Hmm", message: error.localizedDescription, okButtonText: "OK")
                                }
                            }
                        case .failure(let error):
                            LottieHUD.shared.dismiss()
                            self.displaySimpleAlert(title: "Error", message: error.localizedDescription, okButtonText: "OK")
                    }
                }
            }
        }
    }
    // MARK: - Private Methods
    /// Get's the home id of the current user if the homeID exists..
    /// - Returns: home id or empty string.
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
    /// Creates a new home object on the server.
    /// - Parameter anniversaryDateString: Anniversary data in string.
    private func createANewHome(anniversaryDateString: String) {
        Task {
            let dateString = getFormattedDateForBackend(from: anniversaryDateString)
            guard !dateString.isEmpty else {
                displaySimpleAlert(title: "Error", message: "Try again.", okButtonText: "OK") {
                    self.askForAnniversary()
                }
                return
            }
            let homeID = await self.getHomeID()
            guard let userIDString = AppGlobal.shared.user?.id.uuidString else { return }
            let dict = ["id": homeID, "anniversary_date": dateString]
            let homeTable = SensitiveData.supabase.database.from("homes").upsert(values: dict)
            try await homeTable.execute()
            let partnerIDs: [String] = [userIDString]
            let updateTable = SensitiveData.supabase.database.from("homes").update(values: ["partnerUserIDs": partnerIDs]).eq(column: "id", value: homeID)
            try await updateTable.execute()
            print("create A New Home Success")
            self.dismiss(animated: true)
        }
    }
    /// Converts the given date to the server format.
    /// - Parameter dateString: Raw date string.
    /// - Returns: Server compatible date string.
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
    /// Asks the user for their anniversary.
    private func askForAnniversary() {
        self.displayAlertWithTextfield(title: "What is your anniversary?", message: "Please type in \"DD.MM.YYYY\" format.", okButtonText: "Go!", cancelButtonText: "Cancel", placeholder: "(e.g 15.01.1999)") { dateString in
            self.createANewHome(anniversaryDateString: dateString)
        }
    }
    /// Checks if the home is available to user or not.
    /// - Parameters:
    ///   - idString: home id to check
    ///   - completion: returns the homeID if the home is available, returns error if not.
    private func checkHomeData(with idString: String, completion: @escaping (Result<String, CustomMessageError>) -> Void) async {
        let userHasHome = await checkIfUserHasAHome()
        guard userHasHome == false else {
            completion(.failure(.init(message: "You already have a home.")))
            return
        }
        let homeExists = await checkIfHomeExists(with: idString)
        guard homeExists == true else {
            completion(.failure(.init(message: "The home you're looking for doesn't exist.")))
            return
        }
        let homeAvailable = await checkIfHomeIsAvailable(with: idString)
        guard homeAvailable else { 
            completion(.failure(.init(message: "The home you try to enter is full. Unfortunately our homes are for 2 people only at the moment. Please talk with your partner(s).")))
            return
        }
        completion(.success(idString))
    }

    /// Checks if the current  user has a home already.
    /// - Returns: If the user already  has a home or some error occured, returns true.
    private func checkIfUserHasAHome() async -> Bool {
        do {
            guard let userID = AppGlobal.shared.user?.id.uuidString else { return true }
            let homeIDString = try await SensitiveData.supabase.database.from("users").select(columns: "homeID", head: false).eq(column: "userID", value: userID).execute().underlyingResponse.data.convertDataToString().convertStringToDictionary()?["homeID"] as? String ?? ""
            let usersHomeExists = await checkIfHomeExists(with: homeIDString)
            guard usersHomeExists == false else { return true }
            return false
        } catch let error {
            print(error.localizedDescription)
            return true
        }
    }
    /// Checks if the home with the given id exists or not.
    /// - Parameter idString: Home ID to check.
    /// - Returns: true if the home exists. Returns false if home doesn't exist or some error occured.
    private func checkIfHomeExists(with idString: String) async -> Bool {
        do {
            let homeDict = try await SensitiveData.supabase.database.from("homes").select(columns: "*", head: false).eq(column: "id", value: idString).execute().underlyingResponse.data.convertDataToString().convertStringToDictionary()
            guard homeDict != nil else { return false }
            return true
        } catch let error {
            print(error.localizedDescription)
            return false
        }
    }
    /// Checks if the home with the given id has less than 2 people.
    /// - Parameter idString: Home Id to check.
    /// - Returns: true if partnerID count of the home is 1. Returns false if the count is 2 or more.
    private func checkIfHomeIsAvailable(with idString: String) async -> Bool {
        let homePartnerIDs = await getPartnerIDsForHome(with: idString)
        guard let count = homePartnerIDs?.count else { return false }
        return count < 2
    }
    /// Connect's the partners data and homeID
    /// - Parameters:
    ///   - homeID: homeID to update
    ///   - completion: Returns success or error message
    private func connectUserWithHome(homeID: String, completion: @escaping (Result<String, CustomMessageError>) -> Void) {
        Task {
            do {
                guard let userID = AppGlobal.shared.user?.id.uuidString else {
                    completion(.failure(.init(message: "Couldn't fetch your user id. Please try again later.")))
                    return
                }
                // Update Home's partnerIDs
                guard var partnerIDsOfTheRoom = await getPartnerIDsForHome(with: homeID) else {
                    completion(.failure(.init(message: "Couldn't fetch users inside this home. Please try again later.")))
                    return
                }
                let partnerID = partnerIDsOfTheRoom.first ?? ""
                partnerIDsOfTheRoom.append(userID)
                try await SensitiveData.supabase.database.from("homes").update(values: ["partnerUserIDs": partnerIDsOfTheRoom]).eq(column: "id", value: homeID) .execute()
                // Update User's Home ID and Partner ID
                try await SensitiveData.supabase.database.from("users").update(values: ["homeID": homeID, "partnerUserID": partnerID]).eq(column: "userID", value: userID).execute()
                // Update Partner's Partner ID
                try await SensitiveData.supabase.database.from("users").update(values: ["partnerUserID": userID]).eq(column: "userID", value: partnerID).execute()
                completion(.success("Successfully connected you to the home with your partner."))
            } catch let error {
                completion(.failure(.init(message: error.localizedDescription)))
            }
        }
    }
    /// Get's the ids of partners inside a home if the home exists.
    /// - Parameter homeID: homeID to check
    /// - Returns: All ids of the partners inside a home.
    private func getPartnerIDsForHome(with homeID: String) async -> [String]? {
        do {
            let homePartnerIDs = try await SensitiveData.supabase.database.from("homes").select(columns: "partnerUserIDs", head: false).eq(column: "id", value: homeID).execute().underlyingResponse.data.convertDataToString().convertStringToDictionary()?["partnerUserIDs"] as? [String]
            return homePartnerIDs
        } catch let error {
            print(error.localizedDescription)
            return []
        }
    }
}

// MARK: - Alertable
extension CreateOrJoinRoomViewController: Alertable {}
