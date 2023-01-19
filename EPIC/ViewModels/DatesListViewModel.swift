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


@MainActor class DatesListViewModel: ObservableObject {
    
    @Published var datesList = [String]()
    @Published var downloadStatusesList = [DownloadedStatus]()
    @Published var errorMessage: String = ""
    private var cancellables = Set<AnyCancellable>()
    private let networkService = NetworkLayer()
    
    
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
                self?.datesList = dates.map { jsonDate in
                    self?.downloadStatusesList.append(.nothingDownloaded)
                    return jsonDate.date
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
