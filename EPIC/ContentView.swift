//
//  ContentView.swift
//  EPIC
//
//  Created by Alexey Budynkov on 17.01.2023.
//

import Combine
import SwiftUI

struct ContentView: View {
    
    var body: some View {
        VStack {
            DatesListView()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
