//
//  PlayerScreen.swift
//  EPIC
//
//  Created by Alexey Budynkov on 19.01.2023.
//

import SwiftUI

struct PlayerScreen: View {
    
    let images:[UIImage]
    // Index of the currently displayed image
    @State var activeImageIndex = 0

    let imageSwitchTimer = Timer.publish(every: 0.4, on: .main, in: .common)
                                .autoconnect()
    
    
    var body: some View {
        Image(uiImage: images[activeImageIndex])
            .resizable()
            .scaledToFit()
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .onReceive(imageSwitchTimer) { _ in
                // Go to the next image. If this is the last image, go
                // back to the image #0
                self.activeImageIndex = (self.activeImageIndex + 1) % self.images.count
            }
    }
}

//struct PlayerScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        PlayerScreen()
//    }
//}
