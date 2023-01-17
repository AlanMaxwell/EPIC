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
            DatesList()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
