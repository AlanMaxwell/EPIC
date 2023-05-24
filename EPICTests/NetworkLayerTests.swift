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
    
    var networkLayer: NetworkLayerProtocol!
//    var cancellable: AnyCancellable!
    
    private var cancellables = Set<AnyCancellable>()
    
    var app:XCUIApplication!
//
//    override func setUp() {
//        self.app = XCUIApplication()
//        self.app.launch()
//        networkLayer = NetworkLayerFactory.create()
//    }
//
    override func tearDown() {
        networkLayer = nil
    }

    var urlSession: URLSession!

    override func setUpWithError() throws {
        // Set url session for mock networking
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        urlSession = URLSession(configuration: configuration)
        
        networkLayer = NetworkLayer()
    }
    
    func testGetProfile() throws {
        // Profile API. Injected with custom url session for mocking
        networkLayer = NetworkLayer(urlSession: urlSession)
        
        // Set mock data
        let setDate = JsonDate(date: "20.01.2025")
        let mockData = try JSONEncoder().encode([setDate])
        
        // Return data in mock request handler
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(), mockData)
        }
        
        // Set expectation. Used to test async code.
        let expectation = XCTestExpectation(description: "response")
        
        networkLayer.fetchDates()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                    //self?.handleError(error)
                }
            }, receiveValue: { [weak self] dates in
                print(dates)
//                self?.datesList = dates.map { jsonDate in
//                    self?.downloadStatusesList.append(.nothingDownloaded)
//                    return jsonDate.date
//                }
//                self?.errorMessage = ""
            })
            .store(in: &cancellables)
        
        // Make mock network request to get profile
//        profileAPI.getProfile { user in
//            // Test
//            XCTAssertEqual(user.name, "Yugantar")
//            expectation.fulfill()
//        }
//        wait(for: [expectation], timeout: 1)
    }
    
    func testFetchJSONSuccessful() {
        let url = URL(string: "https://epic.gsfc.nasa.gov/api/enhanced/all")!
        let expectation = self.expectation(description: "Fetch JSON")
        var result: Result<[JsonDate], Error>?
        
        networkLayer.fetchJSON(from: url)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    expectation.fulfill()
                case .failure(let error):
                    result = .failure(error)
                }
            }, receiveValue: { value in
                result = .success(value)
            })
            .store(in: &self.cancellables)
        
        waitForExpectations(timeout: 5)
        
        
        switch result {
        case .success(let posts):
            XCTAssertNotNil(posts)
        case .failure(let error):
            XCTFail("Error: \(error)")
        case .none:
            XCTFail("None")
        }

    }
    
    func testFetchJSON() {
        
        let validURL = URL(string: "https://epic.gsfc.nasa.gov/api/enhanced/all")!
        let invalidURL = URL(string: "https://epic.gsfc.gunasa.gov/api/enhanced")!
        
        let networkLayer = NetworkLayer()
        
        let validJSONPublisher:AnyPublisher<[JsonDate], Error> = networkLayer.fetchJSON(from: validURL)
        let invalidJSONPublisher:AnyPublisher<[JsonDate], Error> = networkLayer.fetchJSON(from: invalidURL)
        
        validJSONPublisher
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
            .store(in: &cancellables)


        invalidJSONPublisher
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
            .store(in: &cancellables)
    }
    
}

