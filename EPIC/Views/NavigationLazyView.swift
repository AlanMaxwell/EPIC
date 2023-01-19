//
//  NavigationLazyView.swift
//  EPIC
//
//  Created by Alexey Budynkov on 18.01.2023.
//

import SwiftUI

struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }

    var body: Content {
        build()
    }
}
