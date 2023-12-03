//
//  PhotosViewController.swift
//  coupleZoneTest
//
//  Created by Murat Can KOÇ on 18.10.2023.
//

import UIKit
import TOCropViewController

@MainActor protocol PhotosDisplayLogic: AnyObject {
    func display(_ model: PhotosModels.FetchData.ViewModel)
    func displayError(_ errorString: String)
    func displaySuccessAfterPhotoUpload()
    func displaySuccessAfterUpdateNotificationTime(_ model: PhotosModels.UpdateNotificationTime.ViewModel)
    func displayNotificationTime(_ model: PhotosModels.GetNotificationTime.ViewModel)
}

class PhotosViewController: UIViewController {

    // MARK: - UI Elements
    private lazy var lastPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "bicycle")
        imageView.tintColor = .monkeyBlue
        imageView.contentMode = .scaleAspectFill
        imageView.round(corners: .allCorners, radius: 10)
        imageView.addBorder(borderColor: .monkeyBlue, borderWidth: 2)
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(lastPhotoImageViewAction))
        imageView.addGestureRecognizer(gestureRecognizer)
        imageView.backgroundColor = .systemPink
        return imageView
    }()

    private lazy var timelineTableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PhotosTableViewCell.self, forCellReuseIdentifier: PhotosTableViewCell.cellIdentifier)
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
//        tableView.round(corners: .allCorners, radius: 4)
        tableView.showsVerticalScrollIndicator = true
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemPink
        return tableView
    }()

    private lazy var streakLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .LilacClouds.lilac4
        label.textAlignment = .center
        label.round(corners: .allCorners, radius: 4)
        label.addBorder(borderColor: .LilacClouds.lilac4, borderWidth: 2)
        return label
    }()

    // MARK: Private Properties
    private let router: PhotosRouter
    private let interactor: PhotosBusinessLogic
    private var items = [PhotosModels.FetchData.ViewModel.DisplayableModel]()

    // MARK: Initializers
    init(interactor: PhotosBusinessLogic, router: PhotosRouter) {
        self.interactor = interactor
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: - Lifecycle
    override func loadView() {
        super.loadView()
        setup()
        layout()
        configureNavigationBar()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        LottieHUD.shared.show()
        interactor.fetchData(.init())
    }
    // MARK: - Setup
    private func setup() {
        view.backgroundColor = .systemPink
        view.addSubview(timelineTableView)
        view.addSubview(lastPhotoImageView)
        view.addSubview(streakLabel)
    }

    private func layout() {
        lastPhotoImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.equalTo(10)
            make.trailing.equalTo(-10)
            make.height.equalToSuperview().multipliedBy(0.4)
        }
        timelineTableView.snp.makeConstraints { make in
            make.top.equalTo(lastPhotoImageView.snp.bottom).offset(5)
            make.leading.equalTo(25)
            make.trailing.equalTo(-25)
            make.bottom.equalTo(streakLabel.snp.top).offset(-20)
        }
        streakLabel.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-25)
            make.leading.equalTo(40)
            make.trailing.equalTo(-40)
            make.height.equalTo(30)
        }
    }

    // MARK: - Private Methods
    @MainActor private func configureNavigationBar() {
        let takePhotoButton = UIBarButtonItem(image: UIImage(systemName: "flame"), style: .done, target: self, action: #selector(takePhotoButtonAction))
        navigationItem.rightBarButtonItems = [takePhotoButton]
        navigationItem.rightBarButtonItem?.tintColor = .monkeyBlue
        let timeButton = UIBarButtonItem(image: UIImage(systemName: "clock"), style: .done, target: self, action: #selector(timeButtonAction))
        navigationItem.rightBarButtonItems = [takePhotoButton]
        navigationItem.rightBarButtonItem?.tintColor = .monkeyBlue
        navigationItem.leftBarButtonItems = [timeButton]
        navigationItem.leftBarButtonItem?.tintColor = .monkeyBlue

        let titleViewLabel : UILabel = {
            let label = UILabel()
            label.text = "Caution, Hot Area!"
            label.textColor = .LilacClouds.lilac4
            label.font = .systemFont(ofSize: 20, weight: .bold)
            return label
        }()
        navigationItem.titleView = titleViewLabel
    }
    @MainActor private func scrollToBottom() {
        let row = timelineTableView.numberOfRows(inSection: 0) - 1
        guard row > 0 else { return }
        let indexPath = IndexPath(row: row, section: 0)
        timelineTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    // MARK: - Public Methods
    @MainActor func presentCustomCamera() {
        let customCameraController = CustomCameraViewController()
        customCameraController.delegate = self
        customCameraController.modalPresentationStyle = .fullScreen
        present(customCameraController, animated: true)
    }

    // MARK: - Actions
    @objc private func takePhotoButtonAction() {
        displayAlertTwoButtons(title: "Send Photo", message: "It's getting hot in here!", firstButtonText: "I changed my mind.", firstButtonStyle: .destructive, seconButtonText: "Take Photo!", secondButtonStyle: .default) {
            self.displaySimpleAlert(title: "Why?", message: ":(", okButtonText: "...")
        } secondButtonCompletion: {
            self.presentCustomCamera()
        }
    }
    @objc private func timeButtonAction() {
        let alertController = UIAlertController(title: "\n\n\n\n\n\n\n\n", message: "\n\nChoose your time wisely!\nYou and your partner will be notified everyday!", preferredStyle: .actionSheet)

        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .wheels
        picker.minuteInterval = 1
        picker.locale = Locale(identifier: "en_GB")
        picker.frame = CGRect(x: 0, y: 0, width: alertController.view.frame.width - 20, height: 200)
        
        var hourToDisplay = 0
        var minuteToDisplay = 0
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        // Set the initial time with server data
        interactor.getPhotoNotificationTime(.init()) { serverDateString in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"


            if let date = dateFormatter.date(from: serverDateString) {
                dateFormatter.dateFormat = "HH:mm"
                let convertedDateString = dateFormatter.string(from: date)

                // Split the convertedDateString into hours and minutes
                let components = convertedDateString.components(separatedBy: ":")
                
                if components.count == 2, let hours = Int(components[0]), let minutes = Int(components[1]) {
                    print("Hours: \(hours), Minutes: \(minutes)")
                    hourToDisplay = hours
                    minuteToDisplay = minutes
                } else {
                    print("Invalid time string format")
                }
            } else {
                print("Invalid date string format")
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            let calendar = Calendar.current
            var components = DateComponents()
            components.hour = hourToDisplay
            components.minute = minuteToDisplay
            picker.setDate(calendar.date(from: components)!, animated: true)

            alertController.view.addSubview(picker)

            let doneAction = UIAlertAction(title: "Done", style: .default) { _ in
                let selectedTime = picker.date // Retrieve the selected date from the picker

                // Get the current calendar and components
                let calendar = Calendar.current
                let currentYear = calendar.component(.year, from: Date())
                let currentMonth = calendar.component(.month, from: Date())

                // Extract time components from the selected time
                let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: selectedTime)

                // Construct a new date with current year, month, and extracted time components
                var updatedComponents = DateComponents()
                updatedComponents.year = currentYear
                updatedComponents.month = currentMonth
                updatedComponents.hour = timeComponents.hour
                updatedComponents.minute = timeComponents.minute
                updatedComponents.second = timeComponents.second

                if let updatedDate = calendar.date(from: updatedComponents) {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

                    let formattedTimeString = dateFormatter.string(from: updatedDate)
                    print("Formatted time: \(formattedTimeString)")

                    self.interactor.updatePhotoNotificationTime(.init(notificationTime: formattedTimeString))
                } else {
                    print("Error creating updated date")
                }
            }

            alertController.addAction(doneAction)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            self.present(alertController, animated: true, completion: nil)
        }
        
        

    }
    @objc private func lastPhotoImageViewAction() {
        guard let image = lastPhotoImageView.image else { return }
        let viewController = LastPhotoViewController(photo: image)
        self.present(viewController, animated: true)
    }
}

// MARK: - Alertable
extension PhotosViewController: Alertable {}


// MARK: - Display Logic
extension PhotosViewController: PhotosDisplayLogic {
    func displayError(_ errorString: String) {
        self.displaySimpleAlert(title: "Error", message: errorString, okButtonText: "OK")
    }
    func display(_ model: PhotosModels.FetchData.ViewModel) {
        self.items.removeAll()
        model.displayModels.forEach({ item in
            self.items.append(item)
        })
        self.items.sort(by: { $0.uploadDate < $1.uploadDate })
        let lastItem = self.items.last
        DispatchQueue.main.async {
            self.streakLabel.text = "Streak \(self.items.count)!"
            self.lastPhotoImageView.setImage(urlString: lastItem?.imageURLString) {
                LottieHUD.shared.dismiss()
            }
            self.timelineTableView.reloadData {
                self.scrollToBottom()
                LottieHUD.shared.dismiss()
            }
        }
    }
    func displaySuccessAfterPhotoUpload() {
        self.interactor.fetchData(.init())
        self.displaySimpleAlert(title: "Success", message: "", okButtonText: "Olley!")
    }
    func displaySuccessAfterUpdateNotificationTime(_ model: PhotosModels.UpdateNotificationTime.ViewModel) {
        self.displaySimpleAlert(title: "Okay!", message: "You will be notified everyday at \(model.notificationTime)!", okButtonText: "Yay!")
    }
    func displayNotificationTime(_ model: PhotosModels.GetNotificationTime.ViewModel) {
        //
    }
}

// MARK: - UITableView DataSource
extension PhotosViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PhotosTableViewCell.cellIdentifier, for: indexPath) as? PhotosTableViewCell else { return UITableViewCell () }
        let model = PhotosTableViewCell.DisplayableModel(imageURLString: self.items[indexPath.row].imageURLString, uploadTimeString: self.items[indexPath.row].uploadDate, usernameString: self.items[indexPath.row].usernameString)
        cell.configure(with: model)
        return cell
    }
}

// MARK: - UITableView Delegate
extension PhotosViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let urlString = self.items[indexPath.row].imageURLString
        let url = URL(string: urlString)
        self.lastPhotoImageView.setImage(url: url) {
            LottieHUD.shared.dismiss()
        }
    }
}
// MARK: - Custom Camera
extension PhotosViewController: CustomCameraViewControllerDelegate {
    func didSendPhoto(image: UIImage) {
        self.interactor.uploadPhoto(.init(image: image))
    }
    func didCancel() {
        self.displaySimpleAlert(title: "Why?", message: "Why did you cancel? Come on!", okButtonText: "...")
    }
}
