//
//  PhotoList.swift
//  EPIC
//
//  Created by Alexey Budynkov on 18.01.2023.
//

import SwiftUI
import Combine

struct PhotoList: View {
    @StateObject var viewModel: PhotoListViewModel
    @State var showPhotoSheet:Bool = false
    @State var showPlayerSheet:Bool = false
    
    var body: some View {
        
        let imagesList = Array(viewModel.imagesDict.values.map{ $0 })
        
        return GeometryReader { proxy in
            ScrollView {
                
                ZStack{
                    if viewModel.downloadedStatusState == .downloading {
                        ProgressView()
                            .offset(y: proxy.size.height / 2)
                    }
                    
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 4)) {
                        ForEach(imagesList.indices, id: \.self) { index in
                            Image(uiImage: imagesList[index].image.preparingThumbnail(of: CGSize(width: 50, height: 50)) ?? imagesList[index].image)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .onTapGesture {
                                    viewModel.selectedPhoto = imagesList[index]
                                    showPhotoSheet.toggle()
                                }
                        }
                        
                    }
                    
                }
            }
            .navigationBarTitle(Text(""), displayMode: .inline)
            .navigationBarItems(
                trailing:
                    HStack{
                        if viewModel.downloadedStatusState == .allDownloaded {
                            Button {
                                showPlayerSheet.toggle()
                            } label: {
                                Image(systemName: "play")
                                    .resizable()
                            }
                            
                        }
                        else{
                            Button {
                                viewModel.fetchImages()
                            } label: {
                                Image(systemName: "icloud.and.arrow.down")
                                    .resizable()
                            }
                        }
                        Spacer()
                    }
            )
            
            .sheet(isPresented: self.$showPhotoSheet) {
                PhotoScreen(detailedImage: viewModel.selectedPhoto!)
            }
            .sheet(isPresented: self.$showPlayerSheet) {
                PlayerScreen(images: Array(viewModel.imagesDict.values.map{ $0.image }))
            }

        }
    }
}

//struct PhotoList_Previews: PreviewProvider {
//    static var previews: some View {
//        PhotoList(viewModel: PhotoListViewModel(day: "2023-01-13"))
//    }
//}
