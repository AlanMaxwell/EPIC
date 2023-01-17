//
//  DateListRow.swift
//  EPIC
//
//  Created by Alexey Budynkov on 17.01.2023.
//

import SwiftUI

struct DateListRow: View {
    var indicatorState:DownloadedStatus
    var date:String
    
    var body: some View {
        HStack{
            ContentIndicator(indicatorState: indicatorState)
            Spacer()
            Text(date)
        }
        
    }
}


struct DateListRow_Previews: PreviewProvider {
    static var previews: some View {
        DateListRow(indicatorState: .nothingDownloaded, date: "2023-01-13")
    }
}
