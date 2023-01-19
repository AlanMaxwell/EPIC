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
    func fetchDayImagesList(day:String) -> AnyPublisher<[DayImageInfo], Error> {
        guard let url = URL(string: "https://epic.gsfc.nasa.gov/api/enhanced/date/\(day)") else {
            return Fail(error: ServiceError.invalidURL).eraseToAnyPublisher()
        }
        
        return fetchJSON(from: url)
    }
    
    func fetchImage(day:String, imageName:String) -> AnyPublisher<(imageName: String, image: UIImage), Error> {
        guard let url = URL(string: "https://epic.gsfc.nasa.gov/archive/enhanced/\(day)/png/\(imageName).png") else {
            return Fail(error: ServiceError.invalidURL).eraseToAnyPublisher()
        }
        
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
            .map { data in
                (imageName: imageName, image: UIImage(data: data) ?? UIImage())
            }
            .eraseToAnyPublisher()
    }

}
