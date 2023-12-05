//
//  NoteTableViewCell.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 2023-12-04.
//

import UIKit

class NoteTableViewCell: UITableViewCell {

    // MARK: - Identifiers
    static let cellIdentifier = "NoteTableViewCell"

    // MARK: - UI Elements
    private lazy var mainContentView: UIView = {
        let view = UIView()
        return view
    }()
    private lazy var button: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .LilacClouds.lilac1
        imageView.image = UIImage(systemName: "circle")
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(buttonAction(_:)))
        imageView.addGestureRecognizer(gesture)
        return imageView
    }()
    private lazy var contentTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = .LilacClouds.lilac1
        label.text = "Bu bi not"
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setup() {
        contentView.addSubview(mainContentView)
        mainContentView.addSubview(button)
        mainContentView.addSubview(contentTextLabel)
    }

    private func layout() {
        mainContentView.snp.makeConstraints { make in
            make.top.leading.equalTo(10)
            make.bottom.trailing.equalTo(-10)
        }
        button.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
            make.size.equalTo(30)
        }
        contentTextLabel.snp.makeConstraints { make in
            make.leading.equalTo(button.snp.trailing).offset(10)
            make.top.equalToSuperview()
            make.height.greaterThanOrEqualTo(35)
            make.bottom.equalToSuperview()
        }
    }

    // MARK: - Public Methods
    func configure(with model: DisplayableModel) {
        contentTextLabel.text = model.text
    }
    @objc private func buttonAction(_ sender: UITapGestureRecognizer) {
        if button.image == UIImage(systemName: "circle") {
            button.image = UIImage(systemName: "checkmark.circle.fill")
        } else {
            button.image = UIImage(systemName: "circle")
        }
    }
}

extension NoteTableViewCell {
    struct DisplayableModel {
        let text: String
    }
}
