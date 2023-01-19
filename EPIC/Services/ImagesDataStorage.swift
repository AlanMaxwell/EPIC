//
//  ImagesDataStorage.swift
//  EPIC
//
//  Created by Alexey Budynkov on 19.01.2023.
//

import Foundation
import UIKit
import Combine

typealias DayImage = (info: DayImageInfo, image: UIImage)

class ImagesDataStorage {
    private static var shared = ImagesDataStorage()
    
    static func getInstance()->ImagesDataStorage{
        return shared
    }
    
    //day:[imageName:(info, image)])
    var imagesInfo:[String:[String:DayImage]] = [:]
    
    struct DayImageStructure:Equatable {
        var day: String
        var imageName: String
    }
    
    private let networkService = NetworkLayer()
    private var imagesListSubject = PassthroughSubject<String, Error>()
    private var imagesSubject = PassthroughSubject<DayImageStructure, Error>()
    private var cancellables = Set<AnyCancellable>()
    
    var errorMessage:String = ""
    
    var updateClosures = [String:()->Void]()
    var completionClosures = [String:()->Void]()
    private var loadingCounters = [String:Int]()
    
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

                if !strongSelf.imagesInfo.keys.contains(value.day) {
                    strongSelf.imagesInfo[value.day] = [String:DayImage]()
                }
                
                _ = value.imagesInfo.map { dayImageInfo in
                    strongSelf.imagesInfo[value.day]![dayImageInfo.image] = (info: dayImageInfo, image: UIImage(named: "placeholder")!)
                    strongSelf.imagesSubject.send(DayImageStructure(day: value.day, imageName: dayImageInfo.image))
                }
                
                self?.updateClosures[value.day]?()
                
                strongSelf.errorMessage = ""
            })
            .store(in: &cancellables)
        
        imagesSubject
            .removeDuplicates()
            .flatMap { [unowned self] value in
                self.networkService.fetchImage(day: value.day.split(separator: "-").joined(separator: "/"), imageName: value.imageName)
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
                
                self?.imagesInfo[value.day]?[value.imageName]?.image = value.image
                self?.updateClosures[value.day]?()
                self?.errorMessage = ""
                
                if self != nil && !(self!.loadingCounters.keys.contains(value.day)) {
                    self?.loadingCounters[value.day] = 0
                }
                self?.loadingCounters[value.day]! += 1
                
                if self?.loadingCounters[value.day]! == self?.imagesInfo[value.day]!.count {
                    self?.completionClosures[value.day]?()
                }
            })
            .store(in: &cancellables)
    }
    
    func fetchImages(day:String, updateAction:@escaping ()->Void){
        self.imagesListSubject.send(day)
        self.updateClosures[day] = updateAction
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
