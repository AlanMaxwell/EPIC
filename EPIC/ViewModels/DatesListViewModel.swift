//
//  DatesListViewModel.swift
//  EPIC
//
//  Created by Alexey Budynkov on 17.01.2023.
//

import Foundation
import Combine
import UIKit

enum DownloadedStatus {
    case nothingDownloaded
    case downloading
    case allDownloaded
}

struct DatesListRow: Hashable {
    var date: String
    var status: DownloadedStatus
}

class DatesListViewModel: ObservableObject {
    
    @Published var datesListRows = [DatesListRow]()
    @Published var imagesList = [String:[String:String]]()
    
    @Published var errorMessage: String = ""
    private var cancellables = Set<AnyCancellable>()
    private let networkService = NetworkLayer()

    private var imagesListSubject = PassthroughSubject<String, Error>()
    
    init() {
        imagesListSubject
            .removeDuplicates()
            .flatMap { [unowned self] day in
                self.networkService.fetchDayImagesList(day: day)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.handleError(error)
                }
            }, receiveValue: { [weak self] value in
                guard let strongSelf = self else { return }
                
                let day = value.first!.key
                let imagesInfo = value.first!.value
                if strongSelf.imagesList.keys.contains(day) {
                    strongSelf.imagesList[day] = [:]
                }

                _ = imagesInfo.map { dayImage in
                    if !strongSelf.imagesList.keys.contains(dayImage.image) {
                        strongSelf.imagesList[day] = [dayImage.identifier:dayImage.image]
                    }
                }

                strongSelf.errorMessage = ""
            })
            .store(in: &cancellables)
    }

    
    func loadExamples() {
        networkService.fetchDates()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.handleError(error)
                }
            }, receiveValue: { [weak self] dates in
                self?.datesListRows = dates.map { jsonDate in
                    self?.imagesListSubject.send(jsonDate.date)
                    return DatesListRow(date: jsonDate.date, status: .nothingDownloaded)
                }
                self?.errorMessage = ""
            })
            .store(in: &cancellables)
    }
    
    private func handleError(_ error: Error) {
        switch error {
        case ServiceError.invalidURL:
            errorMessage = "Invalid URL"
        case ServiceError.noInternetConnection:
            errorMessage = "No internet connection"
        case ServiceError.requestTimeout:
            errorMessage = "Request timeout"
        case ServiceError.networkError:
            errorMessage = "Network error"
        case ServiceError.statusCodeError(let code):
            errorMessage = "Error with status code: \(code ?? 0)"
        default:
            errorMessage = "Unexpected error"
        }
        print("\(errorMessage):\(error.localizedDescription)")
    }
}
