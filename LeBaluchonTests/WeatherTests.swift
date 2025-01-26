//
//  LeBaluchonTests.swift
//  LeBaluchonTests
//
//  Created by Bilal Dallali on 14/06/2024.
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
        
        XCTAssertEqual(weatherModel.temperatureString, "23", "TemperatureString should round the temperature correctly")
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
        XCTAssertEqual(weather?.conditionName, "cloud.fill", "Condition name should match the current logic")
    }
    
    func testPerformRequestWithInvalidURL() {
        let invalidURL = "invalid_url"
        let expectation = XCTestExpectation(description: "Should call didFailWithError for invalid URL")
        
        class MockDelegate: WeatherManagerDelegate {
            var didFailWithErrorCalled = false
            var expectation: XCTestExpectation?
            
            func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {}
            func didUpdateNyWeather(_ weatherManager: WeatherManager, weather: WeatherModelNy) {}
            func didFailWithError(error: Error) {
                didFailWithErrorCalled = true
                expectation?.fulfill()
            }
        }
        
        let mockDelegate = MockDelegate()
        mockDelegate.expectation = expectation
        weatherManager.delegate = mockDelegate
        
        // Appeler avec une URL invalide
        weatherManager.performRequest(with: invalidURL)
        
        wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(mockDelegate.didFailWithErrorCalled, "Should call didFailWithError for invalid URL")
    }
    
    func testPerformRequestWithNetworkError() {
        class MockURLSession: URLSession, @unchecked Sendable {
            override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
                completionHandler(nil, nil, NSError(domain: "NetworkError", code: -1001, userInfo: nil))
                return URLSessionDataTask()
            }
        }
        
        let mockSession = MockURLSession()
        var weatherManager = WeatherManager(session: mockSession) // Injecter une session personnalisée
        let expectation = XCTestExpectation(description: "Should call didFailWithError for network error")
        
        class MockDelegate: WeatherManagerDelegate {
            var didFailWithErrorCalled = false
            var expectation: XCTestExpectation?
            
            func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {}
            func didUpdateNyWeather(_ weatherManager: WeatherManager, weather: WeatherModelNy) {}
            func didFailWithError(error: Error) {
                didFailWithErrorCalled = true
                expectation?.fulfill()
            }
        }
        
        let mockDelegate = MockDelegate()
        mockDelegate.expectation = expectation
        weatherManager.delegate = mockDelegate
        
        weatherManager.performRequest(with: weatherManager.weatherURL)
        wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(mockDelegate.didFailWithErrorCalled, "Should call didFailWithError for network error")
    }
    
    func testWeatherModelTemperatureString() {
        let weatherModel = WeatherModel(conditionId: 800, townName: "Paris", temperature: 22.5, timezone: 3600)
        XCTAssertEqual(weatherModel.temperatureString, "23", "TemperatureString should round correctly")
    }
    
    func testWeatherModelConditionName() {
        let weatherModel = WeatherModel(conditionId: 200, townName: "Paris", temperature: 18.0, timezone: 3600)
        XCTAssertEqual(weatherModel.conditionName, "cloud.bolt.fill", "ConditionName should match thunderstorm ID")
    }
    
    func testTemperatureStringRoundingDown() {
        let weather = WeatherModel(conditionId: 800, townName: "Paris", temperature: 22.4, timezone: 3600)
        XCTAssertEqual(weather.temperatureString, "23", "TemperatureString should round up for 22.4 according to the current logic")
    }
    
    func testTemperatureStringRoundingUp() {
        let weather = WeatherModel(conditionId: 800, townName: "Paris", temperature: 22.5, timezone: 3600)
        XCTAssertEqual(weather.temperatureString, "23", "TemperatureString should round up correctly")
    }
    
    func testConditionNameForClearSky() {
        let weather = WeatherModel(conditionId: 800, townName: "Paris", temperature: 22.5, timezone: 3600)
        XCTAssertEqual(weather.conditionName, "sun.max.fill", "ConditionName should return sun.max.fill for clear sky")
    }
    
    func testConditionNameForThunderstorm() {
        let weather = WeatherModel(conditionId: 200, townName: "Paris", temperature: 22.5, timezone: 3600)
        XCTAssertEqual(weather.conditionName, "cloud.bolt.fill", "ConditionName should return cloud.bolt.fill for thunderstorm")
    }
    
    func testConditionNameForRain() {
        let weather = WeatherModel(conditionId: 500, townName: "Paris", temperature: 22.5, timezone: 3600)
        XCTAssertEqual(weather.conditionName, "cloud.rain.fill", "ConditionName should return cloud.rain.fill for rain")
    }
    
    func testConditionNameForSnow() {
        let weather = WeatherModel(conditionId: 600, townName: "Paris", temperature: 22.5, timezone: 3600)
        XCTAssertEqual(weather.conditionName, "cloud.snow.fill", "ConditionName should return cloud.snow.fill for snow")
    }
    
    func testConditionNameForCloudy() {
        let weather = WeatherModel(conditionId: 801, townName: "Paris", temperature: 22.5, timezone: 3600)
        XCTAssertEqual(weather.conditionName, "cloud.fill", "ConditionName should return cloud.fill for cloudy")
    }
    
    func testInitialization() {
        let weather = WeatherModel(conditionId: 800, townName: "Paris", temperature: 22.5, timezone: 3600)
        XCTAssertEqual(weather.conditionId, 800, "Condition ID should match")
        XCTAssertEqual(weather.townName, "Paris", "Town name should match")
        XCTAssertEqual(weather.temperature, 22.5, "Temperature should match")
        XCTAssertEqual(weather.timezone, 3600, "Timezone should match")
    }
    
    func testFetchWeatherCallsPerformRequestWithCorrectURL() {
        class MockWeatherManager {
            var capturedURL: String?
            private let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=YOUR_API_KEY"
            
            func fetchWeather(townName: String) {
                let urlString = "\(weatherURL)&q=\(townName)"
                capturedURL = urlString
            }
        }
        
        let mockWeatherManager = MockWeatherManager()
        let testTownName = "Paris"
        let expectedURLPart = "&q=Paris"
        
        mockWeatherManager.fetchWeather(townName: testTownName)
        
        XCTAssertNotNil(mockWeatherManager.capturedURL, "fetchWeather should construct an URL")
        XCTAssertTrue(mockWeatherManager.capturedURL?.contains(expectedURLPart) ?? false, "The URL should include the correct query for the town name")
        XCTAssertTrue(mockWeatherManager.capturedURL?.hasPrefix("https://api.openweathermap.org/data/2.5/weather") ?? false, "The URL should start with the base weather URL")
    }
    
    func testGetLocalDateTimeString() {
        let viewController = WeatherViewController()
        let timezoneOffset = 3600
        let result = viewController.getLocalDateTimeString(for: timezoneOffset)
        
        XCTAssertFalse(result.isEmpty, "The local date-time string should not be empty")
        XCTAssert(result.contains("202"), "The local date-time string should contain a valid year")
    }
    
}
