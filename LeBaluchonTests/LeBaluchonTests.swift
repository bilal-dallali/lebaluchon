//
//  LeBaluchonTests.swift
//  LeBaluchonTests
//
//  Created by Bilal D on 14/06/2024.
//

import XCTest
@testable import LeBaluchon

final class WeatherManagerTests: XCTestCase {

    var weatherManager: WeatherManager!
    
    override func setUpWithError() throws {
        weatherManager = WeatherManager()
    }
    
    override func tearDownWithError() throws {
        weatherManager = nil
    }
    
    func testParseJSONValidData() throws {
        let json = """
            {
                "weather": [{"id": 800, "description": "clear sky"}],
                "main": {"temp": 22.5},
                "name": "Paris",
                "timezone": 3600
            }
            """.data(using: .utf8)!
        
        let weather = weatherManager.parseJSON(weatherData: json)
        
        XCTAssertNotNil(weather, "WeatherModel should not be nil for valid JSON")
        XCTAssertEqual(weather?.conditionId, 800, "Condition ID does not match")
        XCTAssertEqual(weather?.townName, "Paris", "Town name does not match")
        XCTAssertEqual(weather?.temperature, 22.5, "Temperature does not match")
        XCTAssertEqual(weather?.timezone, 3600, "Timezone does not match")
    }
}


final class CurrencyManagerTests: XCTestCase {
    var currencyManager: CurrencyManager!
    
    override func setUpWithError() throws {
        currencyManager = CurrencyManager()
    }
    
    override func tearDownWithError() throws {
        currencyManager = nil
    }
    
    func testParseJSONValidData() throws {
        let json = """
    {
        "rates": {
            "USD": 1.12
        }
    }
    """.data(using: .utf8)!
        
        let currency = currencyManager.parseJSON(currencyData: json)
        
        XCTAssertNotNil(currency, "CurrencyModel should not be nil for valid JSON")
        XCTAssertEqual(currency?.exchangeRate, 1.12, "Exchange rate does not match")
    }
    
    func testFetchCurrencySuccess() throws {
        // Arrange
        let expectation = self.expectation(description: "Currency fetched successfully")
        let mockDelegate = MockCurrencyManagerDelegate(expectation: expectation)
        currencyManager.delegate = mockDelegate
        
        // Act
        currencyManager.performRequest(with: "\(currencyManager.currencyURL)")
        
        // Wait for the expectation
        waitForExpectations(timeout: 5)
        
        // Assert
        XCTAssertTrue(mockDelegate.didUpdateCalled, "Delegate method didUpdateCurrency should be called")
        XCTAssertNil(mockDelegate.error, "No error should occur during success")
    }
}

// Mock Delegate
class MockCurrencyManagerDelegate: CurrencyManagerDelegate {
    var didUpdateCalled = false
    var error: Error?
    var expectation: XCTestExpectation
    
    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }
    
    func didUpdateCurrency(_ currencyManager: CurrencyManager, currency: CurrencyModel) {
        didUpdateCalled = true
        expectation.fulfill()
    }
    
    func didFailWithError(error: Error) {
        self.error = error
        expectation.fulfill()
    }
}
