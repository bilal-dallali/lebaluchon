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
   
}
