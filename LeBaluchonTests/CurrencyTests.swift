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
}
