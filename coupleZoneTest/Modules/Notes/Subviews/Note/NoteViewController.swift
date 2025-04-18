////
////  NoteViewController.swift
////  coupleZoneTest
////
////  Created by Murat Can KOÇ on 2023-12-03.
////
//
//import UIKit
//import SnapKit
//import IQKeyboardManagerSwift
//import Realtime
//
//class NoteViewController: UIViewController {
//
//    // MARK: - UI Elements
//    private lazy var timeLabel: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 12, weight: .regular)
//        label.textColor = .secondaryLabel
//        label.textAlignment = .center
//        let gesture = UITapGestureRecognizer(target: self, action: #selector(timeLabelAction))
//        return label
//    }()
//    private lazy var textView: UITextView = {
//        let textView = UITextView()
//        textView.delegate = self
//        textView.tintColor = .LilacClouds.lilac1
//        textView.autocorrectionType = .no
//        textView.autocapitalizationType = .none
//        textView.keyboardDismissMode = .interactiveWithAccessory
//        textView.inputAccessoryView = createCustomToolbar()
//        textView.enableMode = .enabled
//        textView.keyboardDistanceFromTextField = 100.0
//        textView.font = .systemFont(ofSize: 18, weight: .regular)
//        return textView
//    }()
//    // MARK: - Private Properties
//    let note: NotesModels.FetchData.ViewModel.DisplayableModel
//    let service = NotesServices()
//    var dispatchWorkItem: DispatchWorkItem?
//    var cursorPosition: NSRange = NSRange(location: 0, length: 0)
//    var isTextViewUpdateInProgress = false
//    var didEditNote = false
//    var currentNoteText = ""
//
//    // MARK: - Initializers
//    init(note: NotesModels.FetchData.ViewModel.DisplayableModel) {
//        self.note = note
//        super.init(nibName: nil, bundle: nil)
//    }
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    // MARK: - Lifecycle
//    override func loadView() {
//        super.loadView()
//        setup()
//        layout()
//        configure()
//    }
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        service.connectSocket(noteID: String(self.note.id)) { message in
//            print("DEBUG: ----- NEW MESSAGE FROM SOCKET")
//            print("DEBUG: -----", message)
//            self.handleSocketMessage(message)
//        }
//    }
//    override func viewDidDisappear(_ animated: Bool) {
//        service.disconnectSocket()
//        guard didEditNote else { return }
//        Task {
//            await service.sendNotificationToPartner(title: "Note Updated!", message: "Your Partner edited a note.", pushCategory: .note, notificationSoundString: "typewriter-notification.wav", data: ["noteID": note.id])
//        }
//    }
//    // MARK: - Setup
//    private func setup() {
//        view.addSubview(timeLabel)
//        view.addSubview(textView)
//    }
//    private func layout() {
//        timeLabel.snp.makeConstraints { make in
//            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(2)
//            make.horizontalEdges.equalToSuperview()
//        }
//        textView.snp.makeConstraints { make in
//            make.top.equalTo(timeLabel.snp.bottom).offset(5)
//            make.horizontalEdges.equalToSuperview()
//            make.bottom.equalTo(-50)
//        }
//    }
//    // MARK: - Actions
//    @objc private func timeLabelAction() {
//        displaySimpleAlert(title: "", message: "Created: \(note.createdAt)", okButtonText: "OK", tintColor: .LilacClouds.lilac1)
//    }
//    @objc private func closeTextViewAction() {
//        textView.resignFirstResponder()
//    }
//    @objc private func loveButtonAction() {
//        let heartImageView = UIImageView(image: UIImage(systemName: "heart.fill"))
//        heartImageView.tintColor = .red
//        heartImageView.contentMode = .scaleAspectFit
//        heartImageView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
//        heartImageView.center = view.center
//
//        guard let window = UIApplication.shared.windows.last else { return }
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//            window.addSubview(heartImageView)
//            window.windowLevel = .alert + 1
//
//            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
//                heartImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
//                heartImageView.alpha = 0.0
//            }, completion: { _ in
//                heartImageView.removeFromSuperview()
//            })
//        }
//    }
//    @objc private func switchTodoButtonAction(_ sender: UIBarButtonItem) {
////        let image = UIImage(systemName: "circle")
////        image?.withTintColor(.LilacClouds.lilac1, renderingMode: .alwaysTemplate)
////
////        let attachment = NSTextAttachment()
////        attachment.image = image
////
////        let imageString = NSAttributedString(attachment: attachment)
////        if let currentPosition = textView.selectedTextRange?.start,
////           let startOfLinePosition = textView.tokenizer.position(from: currentPosition, toBoundary: .line, inDirection: UITextDirection.storage(.backward)){
////            let intPosition = textView.offset(from: textView.beginningOfDocument, to: startOfLinePosition)
////            textView.textStorage.insert(imageString, at: intPosition)
////            let base64String = image?.pngData()?.base64EncodedString()
////        }
//
//
//        // Assuming you have an UIImageView instance named imageView and an image to set
//
//        let image = UIImage(systemName: "circle")
//        let imageView = UIImageView(image: image)
//        let imageViewGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewAction(_:)))
//        imageView.isUserInteractionEnabled = true
//        imageView.addGestureRecognizer(imageViewGesture)
//        imageView.tintColor = .LilacClouds.lilac1
//        imageView.contentMode = .scaleAspectFit
//
//        // Render the UIImageView into an UIImage
//        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, 0.0)
//        defer { UIGraphicsEndImageContext() }
//        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
//        let imageFromView = UIGraphicsGetImageFromCurrentImageContext()
//
//        if let image = imageFromView {
//            // Create an NSTextAttachment with the rendered UIImage
//            let attachment = NSTextAttachment()
//            attachment.image = image
//
//            // You can further set the bounds of the attachment as needed
//            attachment.bounds = CGRect(x: 0, y: 0, width: image.size.width*1.2, height: image.size.height*1.2)
//
//            // Now you can use this attachment in an attributed string or UITextView
//            let imageString = NSAttributedString(attachment: attachment)
//            if let currentPosition = textView.selectedTextRange?.start,
//               let startOfLinePosition = textView.tokenizer.position(from: currentPosition, toBoundary: .line, inDirection: UITextDirection.storage(.backward)){
//                let intPosition = textView.offset(from: textView.beginningOfDocument, to: startOfLinePosition)
//                textView.textStorage.insert(imageString, at: intPosition)
////                let base64String = image?.pngData()?.base64EncodedString()
//            }
//        }
//    }
//    @objc private func imageViewAction(_ sender: UIImageView) {
//        if sender.image == UIImage(systemName: "circle") {
//            sender.image = UIImage(systemName: "checkmark.circle")
//        } else {
//            sender.image = UIImage(systemName: "circle")
//        }
//
//    }
//    // MARK: - Private Methods
//    private func configure() {
//        self.title = note.title
//
//        timeLabel.text = getFormattedDate(from: note.createdAt)
//        textView.text = note.note["contentText"] as? String
//    }
//    private func configureNavigationBar(editing: Bool) {
//        if editing {
//            let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(closeTextViewAction))
//            navigationItem.rightBarButtonItems = [doneButton]
//            navigationItem.rightBarButtonItem?.tintColor = .LilacClouds.lilac1
//        } else {
//            navigationItem.rightBarButtonItems = []
//        }
//    }
//    private func createCustomToolbar() -> UIToolbar {
//        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
//        toolbar.barStyle = .default
//
//        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        let switchTodoButton = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .plain, target: self, action: #selector(switchTodoButtonAction(_:)))
//        switchTodoButton.tintColor = .LilacClouds.lilac1
//        let closeKeyboardButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(closeTextViewAction))
//        closeKeyboardButton.tintColor = .LilacClouds.lilac1
//        let loveButton = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: #selector(loveButtonAction))
//        loveButton.tintColor = .LilacClouds.lilac1
//
//        toolbar.setItems([flexibleSpace, switchTodoButton, flexibleSpace, closeKeyboardButton, flexibleSpace, loveButton, flexibleSpace], animated: true)
//        return toolbar
//    }
//    private func getFormattedDate(from date: String) -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
//
//        if let date = dateFormatter.date(from: date) {
//            let outputFormatter = DateFormatter()
//            outputFormatter.dateFormat = "'Created:' MMMM d, yyyy 'at' HH:mm"
//
//            let formattedString = outputFormatter.string(from: date)
//            print(formattedString) // Output example: Created: December 3, 2023 at 19:48
//            return formattedString
//        } else {
//            print("Failed to parse date")
//            return ""
//        }
//    }
//    // MARK: - Socket
//    private func handleSocketMessage(_ message: Message) {
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
//                if self.isTextViewUpdateInProgress && self.textView.isFirstResponder == true {
//                    self.textView.resignFirstResponder()
//                    self.displaySimpleAlert(title: "Editing in progress...", message: "Please wait for your partner to finish.", okButtonText: "OK", tintColor: .LilacClouds.lilac1)
//                }
//                self.textView.text = contextText
//            }
//        }
//    }
//}
//
//// MARK: - TextView Delegate
//extension NoteViewController: UITextViewDelegate {
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        configureNavigationBar(editing: true)
//        isTextViewUpdateInProgress = true
//    }
//    func textViewDidEndEditing(_ textView: UITextView) {
//        configureNavigationBar(editing: false)
//        isTextViewUpdateInProgress = true
//    }
//    func textViewDidChange(_ textView: UITextView) {
//        currentNoteText = textView.text
//        dispatchWorkItem?.cancel()
//
//        dispatchWorkItem = DispatchWorkItem { [weak self] in
//            self?.sendNoteUpdate()
//            self?.didEditNote = true
//        }
//        // Execute the work item after a delay
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: dispatchWorkItem!)
//    }
//    func textViewDidChangeSelection(_ textView: UITextView) {
//        guard !isTextViewUpdateInProgress else { return }
//    }
//    private func sendNoteUpdate() {
//        Task {
//            guard let userID = AppGlobal.shared.user?.id.uuidString else { return }
//            let jsonDict: [String: String] = ["contentText": textView.text ?? "", "lastSenderID": userID]
//            try await SensitiveData.supabase.from("notes").update(["note": jsonDict]).eq("id", value: note.id).execute()
//            try await SensitiveData.supabase.from("notes").update(["edited_at": self.getCurrentDateForServer()]).eq("id", value: note.id).execute()
//        }
//    }
//    private func getCurrentDateForServer() -> String {
//        let dateFormatter = DateFormatter()
//        let format = "yyyy-MM-dd'T'HH:mm:ssZ"
//        dateFormatter.dateFormat = format
//        let currentDate = dateFormatter.string(from: Date())
//        return currentDate
//    }
//}
//
//// MARK: - Alertable
//extension NoteViewController: Alertable {}
