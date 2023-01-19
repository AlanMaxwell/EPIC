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
                NavigationView {
                    
                    VStack(alignment: .leading, spacing: 10) {

                        ScrollView(showsIndicators: false) {
                            LazyVStack {
                                ForEach(viewModel.datesList.indices, id: \.self) { index in
                                    NavigationLink(destination: NavigationLazyView(
                                        PhotoList(viewModel: PhotoListViewModel(day: viewModel.datesList[index], downloadedStatus: $viewModel.downloadStatusesList[index]))
                                    )) {
                                        
                                        DateListRow(indicatorState: viewModel.downloadStatusesList[index], date: viewModel.datesList[index])
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    Divider()
                                }
                            }
                        }
                    }
                    .navigationBarTitle(Text(""), displayMode: .inline)
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
