//
//  ChatViewController.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 18.10.2023.
//

import UIKit
import SnapKit
import AVFAudio
import Supabase
class ChatRoomViewController: UIViewController {

    // MARK: - UI Elements
    private lazy var containerViewFront: UIView = {
        let view = UIView(frame: .zero)
        return view
    }()
    private lazy var containerViewBack: UIView = {
        let view = UIView(frame: .zero)
        return view
    }()
    private lazy var navigationView: NavigationView = {
        let view = NavigationView()
        return view
    }()
    private lazy var emptyLabel: UILabel = {
        let emptyLabel = UILabel()
        emptyLabel.text = "You don't have any messages yet."
        emptyLabel.textAlignment = .center
        emptyLabel.font = .systemFont(ofSize: 20)
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.numberOfLines = 0
        return emptyLabel
    }()

    private lazy var messagesTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MessageTableViewCell.self, forCellReuseIdentifier: MessageTableViewCell.cellIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .onDrag
        tableView.separatorStyle = .none
        return tableView
    }()

    private lazy var textInputView: TextEntryView = {
        let view = TextEntryView(frame: .zero, viewController: self)
        return view
    }()

    // Title View
    private lazy var titleView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()

    private lazy var blurEffectView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let view = UIVisualEffectView(effect: effect)
        return view
    }()

    private lazy var messageOptionsTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MessageOptionsTableViewCell.self, forCellReuseIdentifier: MessageOptionsTableViewCell.cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 40
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 10
        return tableView
    }()


    // MARK: - Private Properties
    private var navigationBarHeight: CGFloat = 0
    private var tabbarHeight: CGFloat = 0
    private var viewmodel: ChatRoomViewModel?
    private var isKeyboardOpen = false
    private var wasKeyboardOpen = false
    private var keyboardSize: CGRect?

    // MARK: - Lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)   {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {
        super.init(nibName: nil, bundle: nil)
        viewmodel = ChatRoomViewModel()
        viewmodel?.delegate = self
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task {
            await setOnlineStatus(.online)
            await getOnlineStatusFromBackend()
            await connectSocket()
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        Task {
            await setOnlineStatus(.offline)
            disconnectSocket()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        layout()
        setTableViewDelegates()
        addObservers()
        fetchMessages()
    }

    //MARK: - Setup
    private func setTableViewDelegates() {
        messagesTableView.delegate = self
        messagesTableView.dataSource = self
        textInputView.delegate = self
    }

    private func setup() {
        view.addSubview(containerViewBack)
        view.addSubview(containerViewFront)
        containerViewBack.addSubview(emptyLabel)
        containerViewBack.addSubview(messagesTableView)
        containerViewBack.addSubview(textInputView)
        containerViewFront.addSubview(navigationView)
    }

    // MARK: - Layout
    private func layout() {
        navigationBarHeight = (navigationController?.navigationBar.frame.size.height)!
        tabbarHeight = (tabBarController?.tabBar.frame.size.height)!

        containerViewBack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        containerViewFront.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
        }

        navigationView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
        }

        emptyLabel.snp.makeConstraints { make in
            make.centerY.equalTo(view.snp.centerY)
            make.left.equalTo(5)
            make.right.equalTo(-5)
            make.height.greaterThanOrEqualTo(40)
        }

        messagesTableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.left.equalToSuperview()
            make.bottom.equalTo(textInputView.snp.top).offset(-5)
        }

        textInputView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(-tabbarHeight)
            make.height.greaterThanOrEqualTo(40)
        }
    }

    // MARK: - Observers
    private func addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appEnteredBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        messagesTableView.addGestureRecognizer(longPressRecognizer)
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }

    // MARK: - Private Functions
    @objc private func fetchMessages() {
        Task {
            await viewmodel?.fetchMessages(completion: {
                DispatchQueue.main.async {
                    self.toggleEmptyView()
                    self.messagesTableView.reloadData()
                    self.scrollToBottom()
                }
                print("DEBUG: messages reloaded from didload")
            })
        }
    }

    private func scrollToBottom() {
        if viewmodel?.messages.isEmpty == false {
            let indexPath = IndexPath(row: (viewmodel?.messages.count ?? 0) - 1, section: 0)
            messagesTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }

    private func toggleEmptyView() {
        if viewmodel?.messages.isEmpty == true {
            emptyLabel.isHidden = false
            messagesTableView.isHidden = true
        } else {
            emptyLabel.isHidden = true
            messagesTableView.isHidden = false
        }
    }

    private func setOnlineStatus(_ status: OnlineStatus) async {
        do {
            let dict = ["onlineStatus": status.rawValue]
            try await SensitiveData.supabase.from("users").update(dict).eq("userID", value: AppGlobal.shared.user?.id.uuidString ?? "").execute()
            print("DEBUG: ----- OnlineStatus Change")
        } catch let error {
            print(error.localizedDescription)
        }
    }

    // MARK: - Socket Operations
    private func connectSocket() async {
        Task {
            connectForMessages()
            connectForOnlineStatus()
        }
    }

    private func connectForMessages() {
        Task {
            do {
                let homeID = try await SensitiveData.supabase.from("users").select("homeID").eq("userID", value: AppGlobal.shared.user?.id.uuidString ?? "").execute().data.convertDataToString().convertStringToDictionary()?["homeID"] as? String ?? ""

                let channel = await SensitiveData.supabase.channel("chatRoom:\(homeID)")

                let changeStream = await channel.postgresChange(
                    AnyAction.self,
                    schema: "public",
                    table: "messages",
                    filter: "homeID=eq.\(homeID)"
                )

                await channel.subscribe()

                for await change in changeStream {
                    fetchMessages()
                    switch change {
                        case .delete(let action): print("DEBUG: ----- Deleted: \(action.oldRecord)")
                        case .insert(let action): print("DEBUG: ----- Inserted: \(action.record)")
                        case .select(let action): print("DEBUG: ----- Selected: \(action.record)")
                        case .update(let action): print("DEBUG: ----- Updated: \(action.oldRecord) with \(action.record)")
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }

    private func connectForOnlineStatus() {
        Task {
            do {
                let partnerIDDict = try await SensitiveData.supabase.from("users").select("partnerUserID").eq("userID", value: AppGlobal.shared.user?.id.uuidString ?? "").execute().data.convertDataToString().convertStringToDictionary()
                let partnerID = partnerIDDict?["partnerUserID"] as? String ?? ""
                let homeID = try await SensitiveData.supabase.from("users").select("homeID").eq("userID", value: AppGlobal.shared.user?.id.uuidString ?? "").execute().data.convertDataToString().convertStringToDictionary()?["homeID"] as? String ?? ""

                let channel = await SensitiveData.supabase.channel("chatRoom:\(homeID)-OnlineStatusChanges")

                let changeStream = await channel.postgresChange(
                    AnyAction.self,
                    schema: "public",
                    table: "users",
                    filter: "userID=eq.\(partnerID)"
                )

                await channel.subscribe()

                for await change in changeStream {
                    switch change {
                        case .delete(let action): print("DEBUG: ----- Deleted: \(action.oldRecord)")
                        case .insert(let action): print("DEBUG: ----- Inserted: \(action.record)")
                        case .select(let action): print("DEBUG: ----- Selected: \(action.record)")
                        case .update(let action):
                            print("DEBUG: ----- Updated: \(action.oldRecord) with \(action.record)")
                            await getOnlineStatusFromBackend()
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }

    private func disconnectSocket() {
        Task {
            let homeID = try await SensitiveData.supabase.from("users").select("homeID").eq("userID", value: AppGlobal.shared.user?.id.uuidString ?? "").execute().data.convertDataToString().convertStringToDictionary()?["homeID"] as? String ?? ""

            let channel = await SensitiveData.supabase.channel("chatRoom:\(homeID)")
            await channel.unsubscribe()
            print("DEBUG: ----- unsubscribed from channel: \(channel)")
        }
    }

    private func getOnlineStatusFromBackend() async {
        do {
            let partnerID = try await SensitiveData.supabase.from("users").select("partnerUserID").eq("userID", value: AppGlobal.shared.user?.id.uuidString ?? "").execute().data.convertDataToString().convertStringToDictionary()?["partnerUserID"] as? String ?? ""
            let partnerStatusString = try await SensitiveData.supabase.from("users").select("onlineStatus").eq("userID", value: partnerID).execute().data.convertDataToString().convertStringToDictionary()?["onlineStatus"] as? String ?? ""
            navigationView.setOnlineStatus(partnerStatusString)
        } catch let error {
            print(error.localizedDescription)
        }
    }

    // MARK: - Keyboard Actions
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            // if keyboard size is not available for some reason, dont do anything
            return
        }
        self.keyboardSize = keyboardSize
        self.isKeyboardOpen = true
        var shouldMoveViewUp = false
        let bottomOfTextField = textInputView.convert(textInputView.bounds, to: self.view).maxY;
        let topOfKeyboard = self.view.frame.height - keyboardSize.height
        if bottomOfTextField > topOfKeyboard {
            shouldMoveViewUp = true
        }
        if(shouldMoveViewUp) {
            let contentInsets = UIEdgeInsets(
                top: keyboardSize.height - self.navigationBarHeight - self.textInputView.frame.size.height,
                left: 0.0,
                bottom: 0.0,
                right: 0.0
            )
            // Getting Default Keyboard Animation Config
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
            let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
            UIView.animate(withDuration: duration, delay: 0.0, options: UIView.AnimationOptions(rawValue: curve), animations: {
                self.view.frame.origin.y = 0 - keyboardSize.height + self.tabbarHeight
                self.messagesTableView.contentInset = contentInsets
                self.messagesTableView.scrollIndicatorInsets = contentInsets
            })
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.isKeyboardOpen = false
        self.view.frame.origin.y = 0
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0 , right: 0.0)

        self.messagesTableView.contentInset = contentInsets
        self.messagesTableView.scrollIndicatorInsets = contentInsets
    }

    @objc func backgroundTap(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    @objc func appEnteredBackground() {
        view.endEditing(true)
    }

    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            wasKeyboardOpen = isKeyboardOpen
            addBlurEffectView()
            // Finding Cell and adding snapshot to blurview
            let touchPointInTableView = sender.location(in: self.messagesTableView)
            guard let indexPath = self.messagesTableView.indexPathForRow(at: touchPointInTableView)  else { return }
            guard let cell = self.messagesTableView.cellForRow(at: indexPath) as? MessageTableViewCell else { return }
            viewmodel?.selectedMessage = cell.message
            _ = sender.location(in: self.view)
            guard let cellCopy = cell.snapshotView(afterScreenUpdates: false) else { return }
            blurEffectView.contentView.addSubview(cellCopy)
            self.view.endEditing(true)
            cellCopy.snp.makeConstraints { make in
                if wasKeyboardOpen {
                    make.left.right.equalToSuperview()
                    make.height.equalTo(cell.snp.height)
                    make.centerY.equalToSuperview()
                } else {
                    make.edges.equalTo(cell.snp.edges)
                }
            }
            UIImpactFeedbackGenerator.init(style: .rigid).impactOccurred()
            addCellOptionsTableView(for: cell, under: cellCopy, touchPoint: touchPointInTableView)
        }
    }

    // MARK: - Blur Effect
    @objc private func addBlurEffectView() {
        blurEffectView.contentView.subviews.forEach({ $0.removeFromSuperview() })
        UIApplication.shared.keyWindow?.addSubview(blurEffectView)
        blurEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        blurEffectView.contentView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(removeBlurEffectView))
        gesture.delegate = self
        blurEffectView.contentView.addGestureRecognizer(gesture)
    }

    @objc private func removeBlurEffectView() {
        blurEffectView.snp.removeConstraints()
        blurEffectView.removeFromSuperview()
        if wasKeyboardOpen {
            textInputView.firstResponderAction()
        }
    }

    @objc private func addCellOptionsTableView(for cell: MessageTableViewCell, under cellCopy: UIView, touchPoint: CGPoint) {
        blurEffectView.contentView.addSubview(messageOptionsTableView)
        messageOptionsTableView.snp.makeConstraints { make in
            make.top.equalTo(cellCopy.snp.bottom).offset(10)
            make.height.equalTo(80)
            make.width.equalTo(100)
            if cell.isBubbleSideLeft {
                make.left.equalTo(cellCopy.snp.left).offset(5)
            } else {
                make.right.equalTo(cellCopy.snp.right).offset(-5)
            }
        }
    }
}

// MARK: UITableView DataSource
extension ChatRoomViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == messagesTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.cellIdentifier, for: indexPath) as? MessageTableViewCell else { return UITableViewCell() }
            guard let message = viewmodel?.messages[indexPath.row] else { return UITableViewCell() }
            cell.configureCell(message: message)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageOptionsTableViewCell.cellIdentifier, for: indexPath) as? MessageOptionsTableViewCell else { return UITableViewCell() }
            cell.configureCell(with: indexPath)
            return cell
        }

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == messagesTableView {
            return viewmodel?.messages.count ?? 0
        } else {
            return 2
        }
    }
}

// MARK: UITableView Delegate
extension ChatRoomViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == messageOptionsTableView {
            let cell = tableView.cellForRow(at: indexPath) as? MessageTableViewCell
            switch indexPath.row {
                case 0:
                    guard let message = viewmodel?.selectedMessage else { return }
                    UIPasteboard.general.string = message.message
                    removeBlurEffectView()
                case 1:
                    guard viewmodel?.selectedMessage?.senderUID != AppGlobal.shared.user?.id.uuidString else {
                        AlertHelper.alertMessage(title: "Error", message: "You can't report yourself.", okButtonText: "OK")
                        return
                    }
                default:
                    break
            }
        }
    }
    private func removeUserFromRoom() {

    }
}

extension ChatRoomViewController: Alertable {}

// MARK: - ChatRoomViewModel Delegate
extension ChatRoomViewController: ChatRoomViewModelDelegate {
    func didChangeDataSource() {
        fetchMessages()
    }
}

// MARK: - TextEntry Delegate
extension ChatRoomViewController: TextEntryViewDelegate {
    func didStartTyping() {
        Task {
            await setOnlineStatus(.typing)
        }
    }
    
    func didEndTyping() {
        Task {
            await setOnlineStatus(.online)
        }
    }
    
    func didShowSimpleAlert(title: String, message: String) {
        displaySimpleAlert(title: title, message: message, okButtonText: "<3", tintColor: .LilacClouds.lilac3)
    }

    func didChangeTextViewSize(height: CGFloat) {
        textInputView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = height
            }
        }
    }

    func didClickSendButton(text: String) {
        guard let viewmodel = viewmodel else { return }
        Task {
            await viewmodel.uploadMessage(message: text)
            self.messagesTableView.reloadData()
            SoundManager.shared.playSound(with: "message-sent-notification")
        }
    }
}

// MARK: - UIGestureRecognizer Delegate
extension ChatRoomViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let touchPoint: CGPoint = touch.location(in: messageOptionsTableView)
        return messageOptionsTableView.hitTest(touchPoint, with: nil) == nil
    }
}

extension ChatRoomViewController {
    enum OnlineStatus: String {
        case online = "Online"
        case offline = "Offline"
        case typing = "typing..."
    }
}
