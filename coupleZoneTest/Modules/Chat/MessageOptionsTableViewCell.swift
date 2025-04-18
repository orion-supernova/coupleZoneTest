//
//  MessageOptionsTableViewCell.swift
//  coupleZoneTest
//
//  Created by muratcankoc on 08/06/2024.
//

import UIKit
import SnapKit

class MessageOptionsTableViewCell: UITableViewCell {

    // MARK: - UI Elements
    private lazy var optionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Report"
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = UIColor(named: "Black-White")
        return label
    }()

    private lazy var optionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "exclamationmark.bubble")
        return imageView
    }()

    private lazy var bottomSeperatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .secondaryLabel
        return view
    }()

    // MARK: - Public Properties
    static let cellIdentifier = "MessageOptionsTableViewCell"

    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        layout()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Setup & Layout
    func setup() {
        contentView.backgroundColor = .secondarySystemFill
        contentView.addSubview(optionTitleLabel)
        contentView.addSubview(optionImageView)
        //contentView.addSubview(bottomSeperatorLine)
    }

    func layout() {
        optionTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(5)
            make.left.equalTo(5)
            make.bottom.equalTo(-5)
        }

        optionImageView.snp.makeConstraints { make in
            make.right.equalTo(-5)
            make.size.equalTo(20)
            make.centerY.equalToSuperview()
        }

        // bottomSeperatorLine.snp.makeConstraints { make in
        //     make.bottom.equalTo(-1)
        //     make.left.right.equalToSuperview()
        //     make.height.equalTo(1)
        // }
    }

    // MARK: - Public Methods
    func configureCell(with indexPath: IndexPath) {
        let viewModel = MessageOptionsTableViewCellViewModel()
        let option = viewModel.prepareOptions(with: indexPath)
        optionTitleLabel.text = option.title
        optionImageView.image = UIImage(systemName: option.imageString ?? "questionmark")
        optionImageView.tintColor = UIColor(named: "Black-White")
    }

    // MARK: - Private Methods

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        optionTitleLabel.text = ""
    }
}

