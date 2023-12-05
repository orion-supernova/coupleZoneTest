//
//  NotesViewController.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 18.10.2023.
//

import UIKit
import SnapKit

@MainActor protocol NotesDisplayLogic: AnyObject {
    func display(_ model: NotesModels.FetchData.ViewModel)
    func displayError(_ errorString: String)
    func displayVoid()
}

class NotesViewController: UIViewController {

    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NotesTableViewCell.self, forCellReuseIdentifier: NotesTableViewCell.cellIdentifier)
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.showsVerticalScrollIndicator = true
        tableView.separatorStyle = .none
        return tableView
    }()
    // MARK: - Private Properties
    let interactor: NotesBusinessLogic
    private var items = [NotesModels.FetchData.ViewModel.DisplayableModel]()

    // MARK: - Initializers
    init(interactor: NotesBusinessLogic) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: - Lifecycle
    override func loadView() {
        super.loadView()
        view.backgroundColor = .systemBackground
        setup()
        layout()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
        interactor.fetchData(.init())
    }
    // MARK: - NavigationBar
    private func configureNavigationBar() {
        let navBarAppearance = UINavigationBarAppearance()
        // Customize the appearance
        navBarAppearance.configureWithDefaultBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor(named: "Black-White")!, .font: UIFont.systemFont(ofSize: 20, weight: .bold)]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "Black-White")!]
        navBarAppearance.backgroundColor = UIColor.systemBackground
        // Set the appearance for the navigation bar
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        navigationController?.navigationBar.tintColor = .LilacClouds.lilac1
        self.title = "Notes"
        self.navigationController?.navigationBar.prefersLargeTitles = true

        let newNoteButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .done, target: self, action: #selector(newNoteButtonAction))
        navigationItem.rightBarButtonItems = [newNoteButton]
        navigationItem.rightBarButtonItem?.tintColor = .LilacClouds.lilac1
    }
    // MARK: - Setup
    private func setup() {
        view.addSubview(tableView)
    }
    private func layout() {
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.equalTo(10)
            make.trailing.equalTo(-10)
            make.bottom.equalToSuperview()
        }
    }
    // MARK: - Actions
    @objc private func newNoteButtonAction() {
        displayAlertWithTextfield(title: "New Note!", message: "Enter a title for your note!", okButtonText: "OK", cancelButtonText: "Cancel", tintColor: .LilacClouds.lilac1) { title in
            self.interactor.createNote(.init(title: title))
        }
    }
}

// MARK: - Display Logic
extension NotesViewController: NotesDisplayLogic {
    func display(_ model: NotesModels.FetchData.ViewModel) {
        self.items.removeAll()
        model.displayableModels.forEach({ model in
            self.items.append(model)
        })
        self.items.sort(by: { $0.editedAt > $1.editedAt })
        tableView.reloadData()
    }
    func displayError(_ errorString: String) {
        displaySimpleAlert(title: "Error", message: errorString, okButtonText: "OK", tintColor: .LilacClouds.lilac1)
    }
    func displayVoid() {
        interactor.fetchData(.init())
    }
}

// MARK: - UITableView DataSource
extension NotesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NotesTableViewCell.cellIdentifier, for: indexPath) as? NotesTableViewCell else { return UITableViewCell () }
        cell.selectionStyle = .none
        cell.round(corners: .allCorners, radius: 10)
        guard let indexModel = self.items[safeIndex: indexPath.section] else { return UITableViewCell() }
        let cellModel = NotesTableViewCell.DisplayableModel(title: indexModel.title, createdAt: indexModel.createdAt, editedAt: indexModel.editedAt)
        cell.configure(with: cellModel)
        return cell
    }
}

// MARK: - UITableView Delegate
extension NotesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? NotesTableViewCell else { return }
        cell.highlightCell()
        guard let indexModel = self.items[safeIndex: indexPath.section] else { return }
        let viewController = NoteViewController(note: indexModel)
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (_, _, completionHandler) in
            self?.displaySimpleAlert(title: "Delete", message: "Soon!", okButtonText: "OK", tintColor: .LilacClouds.lilac1)
//            // Perform delete operation here, based on the indexPath
//            self?.yourDataSourceArray.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .automatic)

            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash")

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false

        return configuration
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
}

// MARK: - Alertable
extension NotesViewController: Alertable {}


