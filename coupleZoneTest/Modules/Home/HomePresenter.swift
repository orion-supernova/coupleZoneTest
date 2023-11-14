//
//  HomePresenter.swift
//  coupleZoneTest
//
//  Created by Murat Koç on 18.10.2023.
//

import UIKit

protocol HomePresentationLogic {
    func present(_ response: HomeModels.FetchData.Response)
}

final class HomePresenter: HomePresentationLogic {
    
    // MARK: Public Properties
    weak var view: HomeDisplayLogic?

    // MARK: Presentation Logic
    func present(_ response: HomeModels.FetchData.Response) {
        switch response.result {
        case .success( let item):
            let displayableModel = HomeModels.FetchData.ViewModel.DisplayableModel.init(model: item)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.view?.display(HomeModels.FetchData.ViewModel(displayModel: displayableModel))
            }
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
}

extension HomeModels.FetchData.ViewModel.DisplayableModel {
    init(model: HomeItem) {
        self.imageURLString =  model.imageURLString

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        if let startDate = dateFormatter.date(from: model.anniversaryDate) {
            let calendar = Calendar.current
            let currentDate = calendar.startOfDay(for: Date()) // Get the current date at midnight
            let startServerDate = calendar.startOfDay(for: startDate) // Get the server's date at midnight
            var componentsForDay = calendar.dateComponents([.day], from: startServerDate, to: currentDate)
            var componentsWithCalendar = calendar.dateComponents([.year, .month, .day], from: startServerDate, to: currentDate)
            // Add 1 day to the result
            if let originalDay = componentsForDay.day {
                componentsForDay.day = nil  // Clear the day component temporarily
                componentsWithCalendar.day = nil  // Clear the day component temporarily

                if let modifiedDay = calendar.date(byAdding: .day, value: originalDay + 1, to: startDate) {
                    let modifiedComponentsWithCalendar = calendar.dateComponents([.year, .month, .day], from: startDate, to: modifiedDay)
                    let modifiedComponentsForDay = calendar.dateComponents([.day], from: startDate, to: modifiedDay)
                    componentsWithCalendar.year = modifiedComponentsWithCalendar.year
                    componentsWithCalendar.month = modifiedComponentsWithCalendar.month
                    componentsWithCalendar.day = modifiedComponentsWithCalendar.day
                    componentsForDay.day = modifiedComponentsForDay.day
                }
            }
            self.numberOfDays = componentsForDay.day ?? 0
            self.numberOfDaysInOrder = [componentsWithCalendar.year ?? 0, componentsWithCalendar.month ?? 0, componentsWithCalendar.day ?? 0]
        } else {
            self.numberOfDays = 0
            self.numberOfDaysInOrder = [0]
        }
        if let email = AppGlobal.shared.user?.email {
            if email == "zeynepozahishali@gmail.com" {
                self.partnerUsername = "cankoç, on the right"
            } else {
                self.partnerUsername = "zeynom, on the left"
            }
        } else {
            self.partnerUsername = "Error"
        }
        self.username = AppGlobal.shared.appleCredentialUserFullName?.givenName ?? "Anonymous"
    }
}
