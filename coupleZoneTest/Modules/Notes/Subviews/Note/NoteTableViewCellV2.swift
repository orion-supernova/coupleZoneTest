//
//  NoteTableViewCellV2.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 2023-12-11.
//

import UIKit

protocol NoteTableViewCellDelegate: AnyObject {
    func textViewDidChange(_ newText: String, at indexPath: IndexPath)
    func didTapReturnKey(newModel: NoteTableViewCellV2.DisplayableModel, completion: @escaping ()->Void)
}

class NoteTableViewCellV2: UITableViewCell {

    // MARK: - Identifiers
    static let cellIdentifier = "NoteTableViewCellV2"

    // MARK: - UI Elements
    private lazy var mainContentView: UIView = {
        let view = UIView()
        return view
    }()
    private lazy var circleButton: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .LilacClouds.lilac1
//        imageView.image = UIImage(systemName: "circle")
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(buttonAction(_:)))
        imageView.addGestureRecognizer(gesture)
        return imageView
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
        textView.isScrollEnabled = false
        textView.font = .systemFont(ofSize: 18, weight: .regular)
        return textView
    }()
    // MARK: - Public Properties
    weak var delegate: NoteTableViewCellDelegate?
    var textDidChange: ((String) -> Void)?
    var model: DisplayableModel!

    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        //
    }

    // MARK: - Setup
    private func setup() {
        contentView.addSubview(mainContentView)
        mainContentView.addSubview(circleButton)
        mainContentView.addSubview(textView)
    }

    private func layout() {
        mainContentView.snp.makeConstraints { make in
            make.top.leading.equalTo(0)
            make.bottom.trailing.equalTo(0)
        }
        circleButton.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.size.equalTo(30)
        }
        textView.snp.makeConstraints { make in
            make.leading.equalTo(circleButton.snp.trailing)
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            print("")
        }
    }

    // MARK: - Public Methods
    func configure(with model: DisplayableModel) {
        self.model = model
        textView.text = model.text
        switch model.todoStatus {
            case .no:
                circleButton.isHidden = true
                break
            case .unchecked:
                circleButton.image = UIImage(systemName: "circle")
                circleButton.isHidden = false
            case .checked:
                circleButton.image = UIImage(systemName: "checkmark.circle.fill")
                circleButton.isHidden = false
        }
    }
    func openKeyboard() {
        self.textView.becomeFirstResponder()
    }
    // MARK: - Private Methods
    @objc private func buttonAction(_ sender: UITapGestureRecognizer) {
        if circleButton.image == UIImage(systemName: "circle") {
            circleButton.image = UIImage(systemName: "checkmark.circle.fill")
        } else {
            circleButton.image = UIImage(systemName: "circle")
        }
    }
    private func createCustomToolbar() -> UIToolbar {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: mainContentView.frame.size.width, height: 44))
        toolbar.barStyle = .default

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let switchTodoButton = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .plain, target: self, action: #selector(switchTodoButtonAction))
        switchTodoButton.tintColor = .LilacClouds.lilac1
        let closeKeyboardButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(closeTextViewAction))
        closeKeyboardButton.tintColor = .LilacClouds.lilac1
        let loveButton = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: #selector(loveButtonAction))
        loveButton.tintColor = .LilacClouds.lilac1

        toolbar.setItems([flexibleSpace, switchTodoButton, flexibleSpace, closeKeyboardButton, flexibleSpace, loveButton, flexibleSpace], animated: true)
        return toolbar
    }
    @objc private func switchTodoButtonAction() {

    }
    @objc private func closeTextViewAction() {
        textView.endEditing(true)
    }
    @objc private func loveButtonAction() {

    }
}
extension NoteTableViewCellV2: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textDidChange?(textView.text)
//        delegate?.textViewDidChange(textView.text, at: indexPath)
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            print("Enter basıldı!!11!111!!!!1")
            guard model.todoStatus != .no else { return true }
            let newIndexPath = IndexPath(row: model.indexPath!.row + 1, section: model.indexPath!.section)
            let newModel = NoteTableViewCellV2.DisplayableModel(text: "", todoStatus: .unchecked, indexPath: newIndexPath)
            delegate?.didTapReturnKey(newModel: newModel) {
                self.textView.becomeFirstResponder()
            }
        }
        return true
    }
}

extension NoteTableViewCellV2 {
    struct DisplayableModel {
        let text: String
        let todoStatus: TodoStatus
        var indexPath: IndexPath?
    }
    enum TodoStatus: String {
        case no
        case unchecked
        case checked

    }
}
