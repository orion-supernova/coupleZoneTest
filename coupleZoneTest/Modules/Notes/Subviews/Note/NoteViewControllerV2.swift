//
//  NoteViewController.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 2023-12-03.
//

import UIKit
import SnapKit
import IQKeyboardManagerSwift
import Realtime

class NoteViewControllerV2: UIViewController {

    // MARK: - UI Elements
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        let gesture = UITapGestureRecognizer(target: self, action: #selector(timeLabelAction))
        return label
    }()
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NoteTableViewCellV2.self, forCellReuseIdentifier: NoteTableViewCellV2.cellIdentifier)
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.showsVerticalScrollIndicator = true
        tableView.separatorStyle = .none
        tableView.separatorInset = .zero
        tableView.allowsSelection = false
        tableView.backgroundColor = .clear
        return tableView
    }()
    // MARK: - Private Properties
    let note: NotesModels.FetchData.ViewModel.DisplayableModel
    let service = NotesServices()
    var dispatchWorkItem: DispatchWorkItem?
    var cursorPosition: NSRange = NSRange(location: 0, length: 0)
    var isTextViewUpdateInProgress = false
    var didEditNote = false
    var currentNoteText = ""
    var textArray: [String] = []
    var noteModelsArray: [NoteTableViewCellV2.DisplayableModel]

    // MARK: - Initializers
    init(note: NotesModels.FetchData.ViewModel.DisplayableModel) {
        self.note = note
        self.noteModelsArray = []
        let contents = note.note["content"] as? [[String: Any]] ?? [[:]]
        for content in contents {
            let note: NoteTableViewCellV2.DisplayableModel = .init(text: content["text"] as! String, todoStatus: NoteTableViewCellV2.TodoStatus(rawValue: content["checkmark"] as! String)!, indexPath: nil)
            self.noteModelsArray.append(note)
        }
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func loadView() {
        super.loadView()
        setup()
        layout()
        configure()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        service.connectSocket(noteID: String(self.note.id)) { message in
            print("DEBUG: ----- NEW MESSAGE FROM SOCKET")
            print("DEBUG: -----", message)
            self.handleSocketMessage(message)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
//        service.disconnectSocket()
//        guard didEditNote else { return }
//        Task {
//            await service.sendNotificationToPartner(title: "Note Updated!", message: "Your Partner edited a note.", pushCategory: .note, notificationSoundString: "typewriter-notification.wav", data: ["noteID": note.id])
//        }
    }
    // MARK: - Setup
    private func setup() {
        view.addSubview(timeLabel)
        view.addSubview(tableView)
    }
    private func layout() {
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(2)
            make.horizontalEdges.equalToSuperview()
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(5)
            make.horizontalEdges.equalToSuperview()
//            make.bottom.equalTo(-50)
            make.bottom.equalToSuperview()
        }
    }
    // MARK: - Actions
    @objc private func timeLabelAction() {
        displaySimpleAlert(title: "", message: "Created: \(note.createdAt)", okButtonText: "OK", tintColor: .LilacClouds.lilac1)
    }
    @objc private func loveButtonAction() {
        let heartImageView = UIImageView(image: UIImage(systemName: "heart.fill"))
        heartImageView.tintColor = .red
        heartImageView.contentMode = .scaleAspectFit
        heartImageView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        heartImageView.center = view.center

        guard let window = UIApplication.shared.windows.last else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            window.addSubview(heartImageView)
            window.windowLevel = .alert + 1

            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
                heartImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
                heartImageView.alpha = 0.0
            }, completion: { _ in
                heartImageView.removeFromSuperview()
            })
        }
    }
    // MARK: - Private Methods
    private func configure() {
        self.title = note.title

        timeLabel.text = getFormattedDate(from: note.createdAt)
        let wholeNote = note.note["contentText"] as? String ?? ""
        textArray = wholeNote.components(separatedBy: CharacterSet.newlines)
        tableView.reloadData()
    }
    private func getFormattedDate(from date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"

        if let date = dateFormatter.date(from: date) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "'Created:' MMMM d, yyyy 'at' HH:mm"

            let formattedString = outputFormatter.string(from: date)
            print(formattedString) // Output example: Created: December 3, 2023 at 19:48
            return formattedString
        } else {
            print("Failed to parse date")
            return ""
        }
    }
    // MARK: - Socket
    private func handleSocketMessage(_ message: RealtimeMessage) {
//        let payload = message.payload
//        let data = payload["data"] as? [String: Any] ?? [:]
//        let record = data["record"] as? [String: Any] ?? [:]
//        let title = record["title"] as? String ?? ""
//        let note = record["note"] as? [String: Any] ?? [:]
//        let contextText = note["contentText"] as? String ?? ""
//        let lastSenderID = note["lastSenderID"] as? String ?? ""
//        guard let userID = AppGlobal.shared.user?.id.uuidString else { return }
//        DispatchQueue.main.async {
//            self.title = title
//            if userID != lastSenderID {
//                if self.isTextViewUpdateInProgress {
//                    self.displaySimpleAlert(title: "Editing in progress...", message: "Please wait for your partner to finish.", okButtonText: "OK", tintColor: .LilacClouds.lilac1)
//                }
//            }
//        }
    }
}
// MARK: - UITableView DataSource
extension NoteViewControllerV2: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noteModelsArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoteTableViewCellV2.cellIdentifier, for: indexPath) as? NoteTableViewCellV2 else { return UITableViewCell() }
        cell.textDidChange = { [weak self] newText in
            self?.tableView.beginUpdates()
            self?.tableView.endUpdates()
        }
        self.noteModelsArray[indexPath.row].indexPath = indexPath
        let model = self.noteModelsArray[indexPath.row]
        cell.configure(with: model)
        cell.delegate = self
        return cell
    }
}
// MARK: - UITableView Delegate
extension NoteViewControllerV2: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.displaySimpleAlert(title: "hm", message: textArray[indexPath.row], okButtonText: "OK")
    }
}

extension NoteViewControllerV2: NoteTableViewCellDelegate {
    func didTapReturnKey(newModel: NoteTableViewCellV2.DisplayableModel, completion: @escaping () -> Void) {
        self.noteModelsArray.insert(newModel, at: newModel.indexPath!.row)
        self.tableView.reloadData {
            completion()
        }
    }
    func textViewDidChange(_ newText: String, at indexPath: IndexPath) {
        // Update your textArray or model data source with newText at the specific indexPath.row
        textArray[indexPath.row] = newText

        // Reload the specific cell at the given indexPath
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}

// MARK: - Alertable
extension NoteViewControllerV2: Alertable {}
