//
//  NetworkLayer.swift
//  EPIC
//
//  Created by Alexey Budynkov on 17.01.2023.
//

import Foundation
import Combine

enum ServiceError: Error {
    case invalidURL
    case noInternetConnection
    case requestTimeout
    case networkError
    case statusCodeError(code: Int?)
    case unknownError
}


class NetworkLayer {
    func fetchJSON<T: Decodable>(from url: URL) -> AnyPublisher<T, Error> {
        return URLSession.shared.dataTaskPublisher(for: url)
                    .mapError { error -> ServiceError in
                        if let urlError = error as? URLError {
                            switch urlError.code {
                            case .notConnectedToInternet:
                                return .noInternetConnection
                            case .timedOut:
                                return .requestTimeout
                            default:
                                return .networkError
                            }
                        } else {
                            return .unknownError
                        }
                    }
                    .tryMap { data, response in
                        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                            throw ServiceError.statusCodeError(code: (response as? HTTPURLResponse)?.statusCode)
                        }
                        return data
                    }
                    .decode(type: T.self, decoder: JSONDecoder())
                    .eraseToAnyPublisher()
    }
    
    func fetchDates() -> AnyPublisher<[JsonDate], Error> {
        guard let url = URL(string: "https://epic.gsfc.nasa.gov/api/enhanced/all") else {
            return Fail(error: ServiceError.invalidURL).eraseToAnyPublisher()
        }
        return fetchJSON(from: url)
    }
}
