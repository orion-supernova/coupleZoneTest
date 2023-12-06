//
//  NotesTableViewCell.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 2023-12-03.
//

import UIKit

class NotesTableViewCell: UITableViewCell {

    // MARK: - Identifiers
    static let cellIdentifier = "NotesTableViewCell"

    // MARK: - UI Elements
    private lazy var mainContentView: UIView = {
        let view = UIView()
        return view
    }()
    private lazy var innerContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.round(corners: .allCorners, radius: 10)
        return view
    }()
    private lazy var infoContentView: UIView = {
        let view = UIView()
        return view
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .LilacClouds.lilac3
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    private lazy var createdAtLabel: UILabel = {
        let label = UILabel()
        label.textColor = .LilacClouds.lilac1
        label.font = .systemFont(ofSize: 14, weight: .regular)
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
        addSubview(innerContentView)
//        mainContentView.addSubview(innerContentView)
        innerContentView.addSubview(infoContentView)
        infoContentView.addSubview(titleLabel)
        infoContentView.addSubview(createdAtLabel)
    }

    private func layout() {
//        mainContentView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
        innerContentView.snp.makeConstraints { make in
//            make.top.equalTo(10)
//            make.leading.equalTo(10)
//            make.trailing.equalTo(-10)
//            make.bottom.equalTo(-10)

            make.edges.equalToSuperview()
        }
        infoContentView.snp.makeConstraints { make in
            make.top.equalTo(5)
            make.leading.equalTo(10)
            make.trailing.equalTo(-10)
            make.bottom.equalTo(-5)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(30)
        }
        createdAtLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    // MARK: - Public Methods
    func configure(with model: DisplayableModel) {
        titleLabel.text = model.title
        createdAtLabel.text = model.formattedDate
    }
    func highlightCell() {
        UIView.animate(withDuration: 0.1, animations: {
            self.innerContentView.backgroundColor = .systemPink
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.innerContentView.backgroundColor = .secondarySystemBackground
            }
        }
    }
}

extension NotesTableViewCell {
    struct DisplayableModel {
        let title: String
        let createdAt: String
        let editedAt: String
        var formattedDate: String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            if let date = dateFormatter.date(from: editedAt) {
                if Calendar.current.isDateInToday(date) {
                    dateFormatter.dateFormat = "'Today', HH:mm"
                } else if Calendar.current.isDateInYesterday(date) {
                    dateFormatter.dateFormat = "'Yesterday', HH:mm"
                } else {
                    dateFormatter.dateFormat = "MMM d, yyyy | HH:mm"
                }
                return dateFormatter.string(from: date)
            }

            return ""
        }
    }
}
