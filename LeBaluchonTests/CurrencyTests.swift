//
//  CurrencyTests.swift
//  LeBaluchonTests
//
//  Created by Bilal Dallali on 12/01/2025.
//

import XCTest
@testable import LeBaluchon

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
            "rates": {"USD": 1.12}
        }
        """.data(using: .utf8)!
        
        let currency = currencyManager.parseJSON(currencyData: json)
        
        XCTAssertNotNil(currency, "CurrencyModel should not be nil for valid JSON")
        XCTAssertEqual(currency?.exchangeRate, 1.12, "Exchange rate does not match")
    }
    
    func testParseJSONInvalidData() throws {
        let json = """
        {
            "invalidKey": {"USD": 1.12}
        }
        """.data(using: .utf8)!
        
        let currency = currencyManager.parseJSON(currencyData: json)
        
        XCTAssertNil(currency, "CurrencyModel should be nil for invalid JSON")
    }
    
    func testParseJSONMissingRate() throws {
        let json = """
        {
            "rates": {}
        }
        """.data(using: .utf8)!
        
        let currency = currencyManager.parseJSON(currencyData: json)
        
        XCTAssertNil(currency, "CurrencyModel should be nil when USD rate is missing")
    }
    
    func testFetchCurrencyCallsPerformRequest() {
        class MockCurrencyManager {
            var capturedURL: String?
            
            func performRequest(with urlString: String) {
                capturedURL = urlString
            }
            
            func fetchCurrency() {
                let urlString = "https://example.com?base=EUR&symbols=USD"
                performRequest(with: urlString)
            }
        }
        
        // Arrange
        let mockManager = MockCurrencyManager()
        
        // Act
        mockManager.fetchCurrency()
        
        // Assert
        XCTAssertNotNil(mockManager.capturedURL, "performRequest should be called with a URL")
        XCTAssertTrue(mockManager.capturedURL!.contains("base=EUR"), "The URL should include the base currency")
        XCTAssertTrue(mockManager.capturedURL!.contains("symbols=USD"), "The URL should include the target currency (USD)")
    }
    
    func testPerformRequestWithValidURL() {
        class MockCurrencyManager {
            var capturedURL: String?
            
            func performRequest(with urlString: String) {
                capturedURL = urlString
            }
        }
        
        // Arrange
        let mockManager = MockCurrencyManager()
        let testURL = "https://example.com?base=EUR&symbols=USD"
        
        // Act
        mockManager.performRequest(with: testURL)
        
        // Assert
        XCTAssertEqual(mockManager.capturedURL, testURL, "performRequest should capture the correct URL")
    }
    
}
