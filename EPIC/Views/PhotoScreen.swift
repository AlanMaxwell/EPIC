//
//  PhotoScreen.swift
//  EPIC
//
//  Created by Alexey Budynkov on 19.01.2023.
//

import SwiftUI

struct PhotoScreen: View {
    
    var detailedImage:DayImage
    
    var body: some View {
        VStack{
            Image(uiImage: detailedImage.image)
                .resizable()
            
            Text("\(detailedImage.info.date)")
            Text("\(detailedImage.info.caption)")
            Text("\(detailedImage.info.image)")
            Text("\(detailedImage.info.version)")
            
            ForEach(detailedImage.info.coords.structText(), id: \.self) {
                Text("\($0)")
            }
            
            
        }
    }
}

//struct PhotoScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        PhotoScreen()
//    }
//}
