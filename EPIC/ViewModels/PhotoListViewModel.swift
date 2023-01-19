//
//  PhotoListViewModel.swift
//  EPIC
//
//  Created by Alexey Budynkov on 19.01.2023.
//

import Foundation
import Combine
import SwiftUI

@MainActor class PhotoListViewModel: ObservableObject {

    @Published var day:String
    @Published var downloadedStatusState:DownloadedStatus
    @Binding private var downloadedStatus:DownloadedStatus {
        didSet{
            self.downloadedStatusState = downloadedStatus
        }
    }
    
    @Published var imagesDict = [String:DayImage]()
    @Published var errorMessage: String = ""
    
    let storage = ImagesDataStorage.getInstance()
    var updateAction: (()->Void)?
    var completeAction: (()->Void)?
    
    init(day:String, downloadedStatus:Binding<DownloadedStatus>){
        self.day = day

        
        self.downloadedStatusState = downloadedStatus.wrappedValue
        self._downloadedStatus = downloadedStatus
        
        //this action will update our view with asyncronous data
        self.updateAction = {[weak self]
            () -> Void in
            self?.imagesDict = self?.storage.imagesInfo[day] ?? [String:DayImage]()
        }
        self.storage.updateClosures[day] = self.updateAction
        
        //this action is required to update the downloading status
        self.completeAction = {[weak self]
            () -> Void in
            self?.downloadedStatus = .allDownloaded
        }
        self.storage.completionClosures[day] = self.completeAction
        
        //check if we have this in cache
        if storage.imagesInfo.keys.contains(day){
            self.imagesDict = storage.imagesInfo[day]!
        }
        
    }
    
    func fetchImages(){
        downloadedStatus = .downloading
        storage.fetchImages(day: self.day, updateAction: self.updateAction!)
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
    
    deinit {
        print("deinit")
    }
}
