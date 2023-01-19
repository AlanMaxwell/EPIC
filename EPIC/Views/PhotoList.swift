//
//  PhotoList.swift
//  EPIC
//
//  Created by Alexey Budynkov on 18.01.2023.
//

import SwiftUI
import Combine


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

/*
процесс таков:
зашёл - нихрена, кроме кнопки начала загрузки наверху
жму кнопку:
 0) Пока идёт скачивание - вижу progressview
 1) Запускается получение списка картинок
 2) Отрисовывается столько placeholder-ов, сколько картинок в списке
 3) Запускается скачивание картинок для каждой из картинок
 4) Сделать thumbnail-ы
*/



struct PhotoList: View {
    @StateObject var viewModel: PhotoListViewModel

    var body: some View {
        
        let imagesList = viewModel.imagesDict.map({ value in value})
        
        return GeometryReader { proxy in
        ScrollView {
            
                ZStack{
                    if viewModel.downloadedStatusState == .downloading {
                        ProgressView()
                            .offset(y: proxy.size.height / 2)
                    }

                    LazyVGrid(columns: Array(repeating: GridItem(), count: 4)) {
                        ForEach(imagesList.indices, id: \.self) { index in
                            Image(uiImage: imagesList[index].value.image)
                                .resizable()
                                .frame(width: 50, height: 50)
//                            Text("\(imagesList[index].key)")
                        }
                        
                    }
                    
                }
            }
            .navigationBarTitle(Text(""), displayMode: .inline)
            .navigationBarItems(
                trailing:
                    HStack{
                        Spacer()
                        Button {
                            viewModel.fetchImages()
                        } label: {
                            if viewModel.downloadedStatusState == .allDownloaded {
                                Image(systemName: "play")
                                    .resizable()
                            }
                            else{
                                Image(systemName: "icloud.and.arrow.down")
                                    .resizable()
                            }
                        }
                    }
            )
            
        }
    }
}

//struct PhotoList_Previews: PreviewProvider {
//    static var previews: some View {
//        PhotoList(viewModel: PhotoListViewModel(day: "2023-01-13"))
//    }
//}
