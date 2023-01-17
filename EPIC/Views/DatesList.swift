//
//  DatesListView.swift
//  EPIC
//
//  Created by Alexey Budynkov on 17.01.2023.
//

import SwiftUI

struct DatesList: View {
    @ObservedObject var viewModel = DatesListViewModel()

    var body: some View {
        VStack {
            if viewModel.errorMessage.isEmpty {
                List {
                    ForEach(viewModel.datesList, id: \.self) { date in
                        Text("\(date)")
                    }
                }
            } else {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
                Button("Refresh") {
                    self.viewModel.loadExamples()
                }
            }
            Spacer()
        }
        .onAppear {
            self.viewModel.loadExamples()
        }
    }
}

struct DatesList_Previews: PreviewProvider {
    static var previews: some View {
        DatesList()
    }
}
