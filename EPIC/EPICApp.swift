//
//  EPICApp.swift
//  EPIC
//
//  Created by Алан Максвелл on 17.01.2023.
//

import SwiftUI

@main
struct EPICApp: App {
    
    //two seconds delay for the launch screen
    init() {
        sleep(2)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
