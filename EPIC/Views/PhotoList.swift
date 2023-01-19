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
                            Image(uiImage: imagesList[index].value.image.preparingThumbnail(of: CGSize(width: 50, height: 50)) ?? imagesList[index].value.image)
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
