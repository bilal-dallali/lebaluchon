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
    
    func testParseJSONNoData() throws {
        let json = "".data(using: .utf8)!
        let weather = weatherManager.parseJSON(weatherData: json)
        XCTAssertNil(weather, "WeatherModel should be nil for empty JSON")
    }
    
    func testParseJSONInvalidData() throws {
        let json = """
        {
            "invalidKey": "invalidValue"
        }
        """.data(using: .utf8)!
        let weather = weatherManager.parseJSON(weatherData: json)
        XCTAssertNil(weather, "WeatherModel should be nil for invalid JSON structure")
    }
    
    func testParseJSONMissingFields() throws {
        let json = """
        {
            "main": {"temp": 22.5},
            "timezone": 3600
        }
        """.data(using: .utf8)!
        let weather = weatherManager.parseJSON(weatherData: json)
        XCTAssertNil(weather, "WeatherModel should be nil if required fields are missing")
    }
    
    func testInvalidURL() {
        let invalidURL = "invalid_url"
        let expectation = XCTestExpectation(description: "Should call didFailWithError for invalid URL")
        
        class MockWeatherManagerDelegate: WeatherManagerDelegate {
            var didFailWithErrorCalled = false
            var expectation: XCTestExpectation?
            
            func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {}
            func didUpdateNyWeather(_ weatherManager: WeatherManager, weather: WeatherModelNy) {}
            func didFailWithError(error: Error) {
                didFailWithErrorCalled = true
                expectation?.fulfill()
            }
        }
        
        let mockDelegate = MockWeatherManagerDelegate()
        mockDelegate.expectation = expectation
        weatherManager.delegate = mockDelegate
        
        weatherManager.performRequest(with: invalidURL)
        
        wait(for: [expectation], timeout: 2)
        XCTAssertTrue(mockDelegate.didFailWithErrorCalled, "Should call didFailWithError for invalid URL")
    }
    
    func testWeatherModelProperties() {
        let weatherModel = WeatherModel(conditionId: 800, townName: "Paris", temperature: 22.5, timezone: 3600)
        
        XCTAssertEqual(weatherModel.temperatureString, "22", "TemperatureString should round the temperature correctly")
        XCTAssertEqual(weatherModel.conditionName, "sun.max.fill", "ConditionName should match the condition ID")
        XCTAssertEqual(weatherModel.description, "Clear sky", "Description should match the condition ID")
    }
    
    func testParseJSONForNewYork() {
        let json = """
        {
            "weather": [{"id": 801, "description": "partly cloudy"}],
            "main": {"temp": 18.3},
            "name": "New York",
            "timezone": -14400
        }
        """.data(using: .utf8)!
        
        let weather = weatherManager.parseJSON(weatherData: json)
        
        XCTAssertNotNil(weather, "WeatherModel should not be nil for valid JSON")
        XCTAssertEqual(weather?.townName, "New York", "Town name does not match")
        XCTAssertEqual(weather?.temperature, 18.3, "Temperature does not match")
        XCTAssertEqual(weather?.conditionName, "cloud.sun.fill", "Condition name does not match")
    }
    
}
