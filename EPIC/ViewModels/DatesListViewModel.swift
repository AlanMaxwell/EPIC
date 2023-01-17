//
//  DatesListViewModel.swift
//  EPIC
//
//  Created by Alexey Budynkov on 17.01.2023.
//

import Foundation
import Combine

class DatesListViewModel: ObservableObject {
    
    @Published var datesList = [String]()
    var errorMessage: String = ""
    private var cancellable: AnyCancellable?
    private let exampleService = NetworkLayer()
    
    func loadExamples() {
        cancellable = exampleService.fetchDates()
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
                    return jsonDate.date
                }
                self?.errorMessage = ""
            })
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
        case ServiceError.unknownError:
            errorMessage = "Unknown error"
        default:
            errorMessage = "Unexpected error"
        }
    }
    
}
