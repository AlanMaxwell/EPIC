//
//  PhotoList.swift
//  EPIC
//
//  Created by Alexey Budynkov on 18.01.2023.
//

import SwiftUI
import Combine


@MainActor class PhotoListViewModel: ObservableObject {
    
    struct DayImageStructure:Equatable {
        var day: String
        var imageName: String
    }
    
    @Published var day:String
    @Published var downloadedStatusState:DownloadedStatus
    @Binding private var downloadedStatus:DownloadedStatus {
        didSet{
            self.downloadedStatusState = downloadedStatus
        }
    }
    
    @Published var imagesDict = [String:DayImage]()
    @Published var errorMessage: String = ""
    
    private let networkService = NetworkLayer()
    private var imagesListSubject = PassthroughSubject<String, Error>()
    private var imagesSubject = PassthroughSubject<DayImageStructure, Error>()
    private var cancellables = Set<AnyCancellable>()
    
    private var loadingCounter = 0
    
    init(day:String, downloadedStatus:Binding<DownloadedStatus>){
        self.day = day
        self.downloadedStatusState = downloadedStatus.wrappedValue
        self._downloadedStatus = downloadedStatus
        
        //check if we have this in cache
        let storage = ImagesDataStorage.getInstance()
        if storage.imagesInfo.keys.contains(day){
            self.imagesDict = storage.imagesInfo[day]!
        }
        
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
                
                if !storage.imagesInfo.keys.contains(day) {
                    storage.imagesInfo[day] = [String:DayImage]()
                }
                
                _ = value.map { dayImageInfo in
                    storage.imagesInfo[day]![dayImageInfo.image] = (info: dayImageInfo, image: UIImage(named: "placeholder")!)
                    self?.imagesSubject.send(DayImageStructure(day: day, imageName: dayImageInfo.image))
                }
                
                self?.imagesDict = storage.imagesInfo[day]!
                
                self?.errorMessage = ""
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
                storage.imagesInfo[day]![value.imageName]!.image = value.image
                self?.imagesDict = storage.imagesInfo[day]!
                self?.errorMessage = ""
                
                self?.loadingCounter+=1
                if self?.loadingCounter == storage.imagesInfo[day]!.count {
                    self?.downloadedStatus = .allDownloaded
                }
            })
            .store(in: &cancellables)
        
    }
    
    func fetchImages(){
        downloadedStatus = .downloading
        self.imagesListSubject.send(self.day)
        
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
