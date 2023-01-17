//
//  NetworkLayerTests.swift
//  EPICTests
//
//  Created by Alexey Budynkov on 17.01.2023.
//

import XCTest
import Combine
@testable import EPIC

final class NetworkLayerTests: XCTestCase {
    
    var networkLayer: NetworkLayer!
    var cancellable: AnyCancellable!
    
    override func setUp() {
        networkLayer = NetworkLayer()
    }
    
    override func tearDown() {
        cancellable = nil
        networkLayer = nil
    }

    
    func testFetchJSON() {
        
        let validURL = URL(string: "https://epic.gsfc.nasa.gov/api/enhanced/all")!
        let invalidURL = URL(string: "https://epic.gsfc.gunasa.gov/api/enhanced")!
        
        let validJSONPublisher:AnyPublisher<[JsonDate], Error> = networkLayer.fetchJSON(from: validURL)
        let invalidJSONPublisher:AnyPublisher<[JsonDate], Error> = networkLayer.fetchJSON(from: invalidURL)
        
        cancellable = validJSONPublisher
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    XCTFail("Fetching JSON with valid URL should not fail, but got error: \(error)")
                }
            }, receiveValue: { json in
                // Verify that the returned JSON is as expected
                XCTAssertEqual(json.last?.date, "2015-06-17")
            })


        cancellable = invalidJSONPublisher
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("Fetching JSON with invalid URL should fail, but got success")
                case .failure(let error as ServiceError):
                    XCTAssertEqual(error, ServiceError.invalidURL)
                case .failure(let error):
                    XCTFail("Fetching JSON with invalid URL should fail with invalid URL error, but got \(error)")
                }
            }, receiveValue: { _ in
                XCTFail("Fetching JSON with invalid URL should fail, but got value")
            })
    }
    
}

