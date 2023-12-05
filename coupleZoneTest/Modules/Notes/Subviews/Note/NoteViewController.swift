//
//  NoteViewController.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 2023-12-03.
//

import UIKit
import SnapKit
import IQKeyboardManagerSwift

class NoteViewController: UIViewController {

    // MARK: - UI Elements
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        let gesture = UITapGestureRecognizer(target: self, action: #selector(timeLabelAction))
        return label
    }()
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.delegate = self
        textView.tintColor = .LilacClouds.lilac1
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.keyboardDismissMode = .interactiveWithAccessory
        textView.inputAccessoryView = createCustomToolbar()
        textView.enableMode = .enabled
        textView.keyboardDistanceFromTextField = 100.0
        textView.font = .systemFont(ofSize: 18, weight: .regular)
        return textView
    }()
    // MARK: - Private Properties
    let note: NotesModels.FetchData.ViewModel.DisplayableModel

    // MARK: - Initializers
    init(note: NotesModels.FetchData.ViewModel.DisplayableModel) {
        self.note = note
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

    }
    // MARK: - Setup
    private func setup() {
        view.addSubview(timeLabel)
        view.addSubview(textView)
    }
    private func layout() {
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(2)
            make.horizontalEdges.equalToSuperview()
        }
        textView.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(5)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(-50)
        }
    }
    // MARK: - Actions
    @objc private func timeLabelAction() {
        displaySimpleAlert(title: "", message: "Created: \(note.createdAt)", okButtonText: "OK", tintColor: .LilacClouds.lilac1)
    }
    @objc private func closeTextViewAction() {
        textView.resignFirstResponder()
    }
    // MARK: - Private Methods
    private func configure() {
        self.title = note.title

        timeLabel.text = getFormattedDate(from: note.createdAt)
        textView.text = note.note["contentText"] as? String
    }
    private func configureNavigationBar(editing: Bool) {
        if editing {
            let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(closeTextViewAction))
            navigationItem.rightBarButtonItems = [doneButton]
            navigationItem.rightBarButtonItem?.tintColor = .LilacClouds.lilac1
        } else {
            navigationItem.rightBarButtonItems = []
        }
    }
    private func createCustomToolbar() -> UIToolbar {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        toolbar.barStyle = .default

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let switchTodoButton = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .plain, target: self, action: #selector(hedeButtonAction))
        switchTodoButton.tintColor = .LilacClouds.lilac1
        let closeKeyboardButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(closeTextViewAction))
        closeKeyboardButton.tintColor = .LilacClouds.lilac1
        let loveButton = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: #selector(loveButtonAction))
        loveButton.tintColor = .LilacClouds.lilac1

        toolbar.setItems([flexibleSpace, switchTodoButton, flexibleSpace, closeKeyboardButton, flexibleSpace, loveButton, flexibleSpace], animated: true)
        return toolbar
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
    @objc private func hedeButtonAction() {
        // Action for Hede button
        displaySimpleAlert(title: "Hm", message: "Soon!", okButtonText: "OK", tintColor: .LilacClouds.lilac1)
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
}

// MARK: - TextView Delegate
extension NoteViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        configureNavigationBar(editing: true)
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        configureNavigationBar(editing: false)
    }
}

// MARK: - Alertable
extension NoteViewController: Alertable {}
