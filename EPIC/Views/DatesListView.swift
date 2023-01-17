//
//  DatesListView.swift
//  EPIC
//
//  Created by Alexey Budynkov on 17.01.2023.
//

import SwiftUI

struct DatesListView: View {
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
            }
            Spacer()
        }
        .onAppear {
            self.viewModel.loadExamples()
        }
    }
}

struct DatesListView_Previews: PreviewProvider {
    static var previews: some View {
        DatesListView()
    }
}
