//
//  PhotosTableViewCell.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 12.11.2023.
//

import UIKit

class PhotosTableViewCell: UITableViewCell {

    // MARK: - Identifiers
    static let cellIdentifier = "PhotosTableViewCell"

    // MARK: - UI Elements
    private lazy var mainContentView: UIView = {
        let view = UIView()
        view.addBorder(borderColor: .monkeyBlue, borderWidth: 1)
        return view
    }()
    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.round(corners: .allCorners, radius: 4)
        return imageView
    }()

    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .LilacClouds.lilac4
        label.font = .systemFont(ofSize: 10, weight: .semibold)
        return label
    }()

    private lazy var uploadTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .LilacClouds.lilac3
        label.font = .systemFont(ofSize: 8, weight: .semibold)
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
        self.backgroundColor = .systemPink
        addSubview(mainContentView)
        mainContentView.addSubview(photoImageView)
        mainContentView.addSubview(usernameLabel)
        mainContentView.addSubview(uploadTimeLabel)
    }

    private func layout() {
        mainContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        usernameLabel.snp.makeConstraints { make in
            make.leading.top.equalTo(5)
        }
        photoImageView.snp.makeConstraints { make in
            make.leading.equalTo(5)
            make.size.equalTo(50)
            make.top.equalTo(usernameLabel.snp.bottom).offset(2)
            make.bottom.equalTo(-5)
        }
        uploadTimeLabel.snp.makeConstraints { make in
            make.trailing.equalTo(-5)
            make.centerY.equalToSuperview()
        }

    }

    // MARK: - Public Methods
    func configure(with model: DisplayableModel) {
        photoImageView.setImage(urlString: model.imageURLString) {
            //
        }
        usernameLabel.text = model.usernameString
        uploadTimeLabel.text = getDateStringForUploadTime(from: model.uploadTimeString)
    }

    // MARK: - Private Methods
    private func getDateStringForUploadTime(from dateString: String) -> String {
        let serverDateFormatter = DateFormatter()
        serverDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"

        if let serverDate = serverDateFormatter.date(from: dateString) {
            let displayDateFormatter = DateFormatter()
            displayDateFormatter.dateFormat = "MMM d, yyyy | HH:mm:ss"

            return displayDateFormatter.string(from: serverDate)
        } else {
            return "Upload Date Error"
        }
    }

}

extension PhotosTableViewCell {
    struct DisplayableModel {
        let imageURLString: String
        let uploadTimeString: String
        let usernameString: String
    }
}
