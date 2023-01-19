//
//  ContentIndicator.swift
//  EPIC
//
//  Created by Alexey Budynkov on 17.01.2023.
//

import SwiftUI

struct ContentIndicator: View {
    var indicatorState:DownloadedStatus
    
    var body: some View {
        HStack {
            switch indicatorState {
            case .nothingDownloaded:
                Image(uiImage: UIImage(named: "circle")!)
                    .resizable()
            case .downloading:
                GeometryReader { proxy in
                    ProgressView()
                        .offset(y: 10)
                }
            case .allDownloaded:
                Image(systemName: "checkmark")
            }
        }
        .frame(width: 30, height: 30)
        
    }
}

struct ContentIndicator_Previews: PreviewProvider {
    static var previews: some View {
        ContentIndicator(indicatorState: .nothingDownloaded)
    }
}
