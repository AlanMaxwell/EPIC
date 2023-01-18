//
//  NetworkLayer.swift
//  EPIC
//
//  Created by Alexey Budynkov on 17.01.2023.
//

import Foundation
import Combine
import UIKit

enum ServiceError: Error, Equatable {
    case invalidURL
    case noInternetConnection
    case requestTimeout
    case networkError
    case statusCodeError(code: Int?)
}


class NetworkLayer {
    func fetchJSON<T: Decodable>(from url: URL) -> AnyPublisher<T, Error> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .mapError { error -> ServiceError in
                switch error.code {
                case .notConnectedToInternet:
                    return .noInternetConnection
                case .timedOut:
                    return .requestTimeout
                default:
                    return .networkError
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
    
    //fetches the images list and adds a day to the result
    func fetchDayImagesList(day:String) -> AnyPublisher<[String:[DayImage]], Error> {
        guard let url = URL(string: "https://epic.gsfc.nasa.gov/api/enhanced/date/\(day)") else {
            return Fail(error: ServiceError.invalidURL).eraseToAnyPublisher()
        }
        
        var publisher: AnyPublisher<[DayImage], Error> = fetchJSON(from: url)

        return publisher
            .map { values in
                return [day:values]
            }
            .eraseToAnyPublisher()
    }
    
    func fetchImage(from url: URL) -> AnyPublisher<UIImage, Error> {
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .mapError { error -> ServiceError in
                switch error.code {
                case .notConnectedToInternet:
                    return .noInternetConnection
                case .timedOut:
                    return .requestTimeout
                default:
                    return .networkError
                }
            }
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw ServiceError.statusCodeError(code: (response as? HTTPURLResponse)?.statusCode)
                }
                return data
            }
            .map { data in UIImage(data: data) }
            .replaceNil(with: UIImage())
            .eraseToAnyPublisher()
    }

}
