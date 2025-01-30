//
//  LeBaluchonTests.swift
//  LeBaluchonTests
//
//  Created by Bilal Dallali on 14/06/2024.
//

import CoreLocation
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
        class MockDelegate: WeatherManagerDelegate {
            var didFailWithErrorCalled = false
            var receivedError: NSError?
            
            func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {}
            func didUpdateNyWeather(_ weatherManager: WeatherManager, weather: WeatherModelNy) {}
            func didFailWithError(error: Error) {
                didFailWithErrorCalled = true
                receivedError = error as NSError
            }
        }
        
        let invalidURL = "invalid_url"
        let mockDelegate = MockDelegate()
        var manager = WeatherManager()
        manager.delegate = mockDelegate
        
        manager.performRequest(with: invalidURL)
        
        XCTAssertTrue(mockDelegate.didFailWithErrorCalled, "Should call didFailWithError for invalid URL.")
        XCTAssertEqual(mockDelegate.receivedError?.domain, "InvalidURLError", "Error domain should be 'InvalidURLError'.")
    }
    
    func testPerformRequestWithNoData() {
        class MockDelegate: WeatherManagerDelegate {
            var didFailWithErrorCalled = false
            var receivedError: NSError?
            
            func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {}
            func didUpdateNyWeather(_ weatherManager: WeatherManager, weather: WeatherModelNy) {}
            func didFailWithError(error: Error) {
                didFailWithErrorCalled = true
                receivedError = error as NSError
            }
        }
        
        let mockSession = SessionMock()
        let mockDelegate = MockDelegate()
        var manager = WeatherManager(session: mockSession)
        manager.delegate = mockDelegate
        
        manager.performRequest(with: manager.weatherURL)
        
        XCTAssertTrue(mockDelegate.didFailWithErrorCalled, "Should call didFailWithError for missing data.")
        XCTAssertEqual(mockDelegate.receivedError?.domain, "NoDataError", "Error domain should be 'NoDataError'.")
    }
    
    func testPerformRequestWithMalformedJSON() {
        let expectation = XCTestExpectation(description: "Should call didFailWithError for malformed JSON")
        
        // Delegate mock
        class MockDelegate: WeatherManagerDelegate {
            var didFailWithErrorCalled = false
            var receivedError: NSError?
            let expectation: XCTestExpectation
            
            init(expectation: XCTestExpectation) {
                self.expectation = expectation
            }
            
            func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {}
            func didUpdateNyWeather(_ weatherManager: WeatherManager, weather: WeatherModelNy) {}
            
            func didFailWithError(error: Error) {
                didFailWithErrorCalled = true
                receivedError = error as NSError
                expectation.fulfill()
            }
        }
        
        // Malformed json to use parseerror
        let invalidJSON = "{ invalid json }".data(using: .utf8)
        
        // Using sessionmock with malformed JSON
        let mockSession = SessionMock(data: invalidJSON)
        let mockDelegate = MockDelegate(expectation: expectation)
        
        var weatherManager = WeatherManager(session: mockSession)
        weatherManager.delegate = mockDelegate
        
        // Act - Execute request
        weatherManager.performRequest(with: weatherManager.weatherURL)
        
        // Wait for simulated response
        wait(for: [expectation], timeout: 1.0)
        
        // Assert - CHecking errors
        XCTAssertTrue(mockDelegate.didFailWithErrorCalled, "Should call didFailWithError for malformed JSON.")
        XCTAssertEqual(mockDelegate.receivedError?.domain, "ParseError", "Error domain should be 'ParseError'.")
        XCTAssertEqual(mockDelegate.receivedError?.localizedDescription, "Failed to parse JSON.", "Error message should indicate parsing failure.")
    }
    
    func testPerformRequestWithNetworkError() {
        class MockURLSession: SessionProtocol {
            func perform(url: URL, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) {
                completionHandler(nil, nil, NSError(domain: "NetworkError", code: -1001, userInfo: nil))
            }
            
            func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
                return MockURLSessionDataTask {
                    completionHandler(nil, nil, NSError(domain: "NetworkError", code: -1001, userInfo: nil))
                }
            }
        }
        
        let mockSession = MockURLSession()
        var weatherManager = WeatherManager(session: mockSession)
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
    
    func testGetLocalDateTimeString() {
        let viewController = WeatherViewController()
        let timezoneOffset = 3600
        let result = viewController.getLocalDateTimeString(for: timezoneOffset)
        
        XCTAssertFalse(result.isEmpty, "The local date-time string should not be empty")
        XCTAssert(result.contains("202"), "The local date-time string should contain a valid year")
    }
    
    func testFetchWeatherCallsPerformRequestWithCorrectURLUsingStruct() {
        struct MockWeatherManager {
            let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=\(weatherApiKey)&units=metric"
            var capturedURL: String?
            
            mutating func performRequest(with urlString: String) {
                capturedURL = urlString
            }
            
            mutating func fetchWeather(townName: String) {
                let urlString = "\(weatherURL)&q=\(townName)"
                performRequest(with: urlString)
            }
        }
        
        var mockManager = MockWeatherManager()
        let testTownName = "Paris"
        let expectedBaseURL = "https://api.openweathermap.org/data/2.5/weather?appid=\(weatherApiKey)&units=metric"
        let expectedQuery = "&q=Paris"
        
        // Act
        mockManager.fetchWeather(townName: testTownName)
        
        // Assert
        XCTAssertNotNil(mockManager.capturedURL, "fetchWeather should construct an URL.")
        XCTAssertTrue(
            mockManager.capturedURL?.hasPrefix(expectedBaseURL) ?? false,
            "The URL should start with the base weather URL."
        )
        XCTAssertTrue(
            mockManager.capturedURL?.contains(expectedQuery) ?? false,
            "The URL should include the correct query for the town name."
        )
    }
    
    func testFetchWeatherCallsPerformRequest() {
        let expectation = XCTestExpectation(description: "Weather fetched")
        
        class MockDelegate: WeatherManagerDelegate {
            var didUpdateWeatherCalled = false
            var receivedWeather: WeatherModel?
            let expectation: XCTestExpectation
            
            init(expectation: XCTestExpectation) {
                self.expectation = expectation
            }
            
            func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
                print("✅ Delegate didUpdateWeather called with weather: \(weather)")
                didUpdateWeatherCalled = true
                receivedWeather = weather
                expectation.fulfill()
            }
            
            func didUpdateNyWeather(_ weatherManager: WeatherManager, weather: WeatherModelNy) {}
            
            func didFailWithError(error: Error) {
                print("❌ Delegate didFailWithError called with error: \(error)")
                expectation.fulfill()
            }
        }
        
        let mockJSON = """
        {
            "coord": {"lon": 2.3488, "lat": 48.8534},
            "weather": [{"id": 800, "main": "Clear", "description": "clear sky"}],
            "main": {
                "temp": 25.0,
                "feels_like": 24.5,
                "temp_min": 23.0,
                "temp_max": 26.0,
                "pressure": 1015,
                "humidity": 65
            },
            "name": "Paris",
            "timezone": 3600
        }
        """.data(using: .utf8)
        let mockSession = SessionMock(data: mockJSON)
        let mockDelegate = MockDelegate(expectation: expectation)
        
        var weatherManager = WeatherManager(session: mockSession)
        weatherManager.delegate = mockDelegate
        
        print("📍 Starting test - fetching weather for Paris")
        weatherManager.fetchWeather(townName: "Paris")
        
        wait(for: [expectation], timeout: 1.0)
        
        // Assert with more details for failure
        XCTAssertTrue(mockDelegate.didUpdateWeatherCalled, "The delegate's didUpdateWeather method was not called")
        
        if let receivedWeather = mockDelegate.receivedWeather {
            print("✅ Received weather: \(receivedWeather)")
        } else {
            print("❌ No weather received")
        }
        
        XCTAssertEqual(mockDelegate.receivedWeather?.townName, "Paris")
        XCTAssertEqual(mockDelegate.receivedWeather?.temperature, 25.0)
        XCTAssertEqual(mockDelegate.receivedWeather?.timezone, 3600)
    }
    
    
    func testPerformNyRequestWithInvalidURL() {
        // Arrange
        class MockDelegate: WeatherManagerDelegate {
            var didFailWithErrorCalled = false
            var receivedError: NSError?
            
            func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {}
            func didUpdateNyWeather(_ weatherManager: WeatherManager, weather: WeatherModelNy) {}
            func didFailWithError(error: Error) {
                didFailWithErrorCalled = true
                receivedError = error as NSError
            }
        }
        
        let mockDelegate = MockDelegate()
        var weatherManager = WeatherManager()
        weatherManager.delegate = mockDelegate
        
        let invalidURL = ""
        
        // Act
        weatherManager.performNyRequest(with: invalidURL)
        
        // Assert
        XCTAssertTrue(mockDelegate.didFailWithErrorCalled, "Should call didFailWithError for an invalid URL.")
        XCTAssertNotNil(mockDelegate.receivedError, "An error should be passed to the delegate.")
        XCTAssertEqual(
            mockDelegate.receivedError?.domain,
            "InvalidURLError",
            "The error domain should be 'InvalidURLError'."
        )
        XCTAssertEqual(
            mockDelegate.receivedError?.localizedDescription,
            "The URL provided is invalid.",
            "The error description should indicate the URL is invalid."
        )
    }
    
    func testDidFailWithErrorForWeatherManager() {
        // Arrange
        class MockDelegate: WeatherManagerDelegate {
            var didFailWithErrorCalled = false
            var receivedError: Error?
            
            func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {}
            func didUpdateNyWeather(_ weatherManager: WeatherManager, weather: WeatherModelNy) {}
            func didFailWithError(error: Error) {
                didFailWithErrorCalled = true
                receivedError = error
            }
        }
        
        let mockDelegate = MockDelegate()
        var weatherManager = WeatherManager()
        weatherManager.delegate = mockDelegate
        
        let testError = NSError(
            domain: "TestErrorDomain",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "Test error message"]
        )
        
        // Act
        weatherManager.delegate?.didFailWithError(error: testError)
        
        // Assert
        XCTAssertTrue(mockDelegate.didFailWithErrorCalled, "didFailWithError should be called when an error occurs.")
        XCTAssertNotNil(mockDelegate.receivedError, "An error should be passed to the delegate.")
        XCTAssertEqual(
            (mockDelegate.receivedError as NSError?)?.localizedDescription,
            "Test error message",
            "The error message should match the test error message."
        )
    }
    
    func testParseNyJSONCallsDidFailWithErrorOnInvalidJSON() {
        // Arrange
        class MockDelegate: WeatherManagerDelegate {
            var didFailWithErrorCalled = false
            var receivedError: NSError?
            
            func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {}
            func didUpdateNyWeather(_ weatherManager: WeatherManager, weather: WeatherModelNy) {}
            func didFailWithError(error: Error) {
                didFailWithErrorCalled = true
                receivedError = error as NSError
            }
        }
        
        let mockDelegate = MockDelegate()
        var weatherManager = WeatherManager()
        weatherManager.delegate = mockDelegate
        
        let invalidJSON = "{ invalid json }".data(using: .utf8)
        
        // Act
        let result = weatherManager.parseNyJSON(weatherData: invalidJSON!)
        
        // Assert
        XCTAssertNil(result, "parseNyJSON should return nil for invalid JSON.")
        XCTAssertTrue(mockDelegate.didFailWithErrorCalled, "didFailWithError should be called for invalid JSON.")
        XCTAssertNotNil(mockDelegate.receivedError, "An error should be passed to didFailWithError.")
        XCTAssertEqual(
            mockDelegate.receivedError?.domain,
            NSCocoaErrorDomain,
            "The error domain should be NSCocoaErrorDomain for JSON decoding errors."
        )
    }
    
    func testPerformRequestCallsDidUpdateWeatherWithValidData() {
        // Arrange
        class MockDelegate: WeatherManagerDelegate {
            var didUpdateWeatherCalled = false
            var receivedWeather: WeatherModel?
            
            func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
                didUpdateWeatherCalled = true
                receivedWeather = weather
            }
            
            func didUpdateNyWeather(_ weatherManager: WeatherManager, weather: WeatherModelNy) {}
            func didFailWithError(error: Error) {}
        }

        let validJSON = """
            {
                "weather": [{"id": 800, "description": "clear sky"}],
                "main": {"temp": 25.0},
                "name": "Paris",
                "timezone": 3600
            }
            """.data(using: .utf8)
        
        let mockSession = SessionMock(data: validJSON)
        let mockDelegate = MockDelegate()
        var weatherManager = WeatherManager(session: mockSession)
        weatherManager.delegate = mockDelegate
        
        // Act
        weatherManager.performRequest(with: "https://mockurl.com")
        
        // Assert
        XCTAssertTrue(mockDelegate.didUpdateWeatherCalled, "didUpdateWeather should be called for valid JSON.")
        XCTAssertNotNil(mockDelegate.receivedWeather, "WeatherModel should not be nil for valid JSON.")
        XCTAssertEqual(mockDelegate.receivedWeather?.townName, "Paris", "The town name should match the JSON data.")
        XCTAssertEqual(mockDelegate.receivedWeather?.temperature, 25.0, "The temperature should match the JSON data.")
        XCTAssertEqual(mockDelegate.receivedWeather?.timezone, 3600, "The timezone should match the JSON data.")
    }
    
    func testFetchWeatherWithMockDataAndCoordinates() {
        let expectation = XCTestExpectation(description: "Weather data fetched")
        
        class MockDelegate: WeatherManagerDelegate {
            var didUpdateWeatherCalled = false
            var receivedWeather: WeatherModel?
            let expectation: XCTestExpectation
            
            init(expectation: XCTestExpectation) {
                self.expectation = expectation
            }
            
            func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
                print("📍 Delegate method called with weather: \(weather)")
                didUpdateWeatherCalled = true
                receivedWeather = weather
                expectation.fulfill()
            }
            
            func didUpdateNyWeather(_ weatherManager: WeatherManager, weather: WeatherModelNy) {
                print("❌ Wrong delegate method called: didUpdateNyWeather")
            }
            
            func didFailWithError(error: Error) {
                print("❌ Error received in delegate: \(error)")
                expectation.fulfill()
            }
        }
        
        let mockJSON = """
    {
        "weather": [{"id": 801, "main": "Clouds", "description": "few clouds"}],
        "main": {
            "temp": 15.0,
            "feels_like": 14.5,
            "temp_min": 14.0,
            "temp_max": 16.0,
            "pressure": 1015,
            "humidity": 76
        },
        "name": "MockCity",
        "timezone": 7200,
        "cod": 200
    }
    """.data(using: .utf8)
        
        let mockSession = SessionMock(data: mockJSON)
        let mockDelegate = MockDelegate(expectation: expectation)
        
        var weatherManager = WeatherManager(session: mockSession)
        weatherManager.delegate = mockDelegate
        
        print("📍 Starting test")
        weatherManager.fetchWeather(latitude: 48.8566, longitude: 2.3522)
        
        // Augmenter le timeout si nécessaire
        wait(for: [expectation], timeout: 2.0)
        
        // Ajouter des messages d'erreur plus descriptifs
        XCTAssertTrue(mockDelegate.didUpdateWeatherCalled, "didUpdateWeather was not called")
        if let receivedWeather = mockDelegate.receivedWeather {
            print("📍 Received weather: \(receivedWeather)")
        } else {
            print("❌ No weather received")
        }
        XCTAssertEqual(mockDelegate.receivedWeather?.townName, "MockCity", "Town name mismatch")
        XCTAssertEqual(mockDelegate.receivedWeather?.temperature, 15.0, "Temperature mismatch")
        XCTAssertEqual(mockDelegate.receivedWeather?.timezone, 7200, "Timezone mismatch")
    }
    
    func testPerformNyRequestCallsDidUpdateNyWeather() {
        let expectation = XCTestExpectation(description: "Weather data for NY fetched")
        
        class MockDelegate: WeatherManagerDelegate {
            var didUpdateNyWeatherCalled = false
            var receivedWeather: WeatherModelNy?
            let expectation: XCTestExpectation
            
            init(expectation: XCTestExpectation) {
                self.expectation = expectation
            }
            
            func didUpdateNyWeather(_ weatherManager: WeatherManager, weather: WeatherModelNy) {
                print("✅ didUpdateNyWeather called")
                didUpdateNyWeatherCalled = true
                receivedWeather = weather
                expectation.fulfill()
            }
            
            func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {}
            
            func didFailWithError(error: Error) {
                print("❌ Error in delegate: \(error.localizedDescription)")
                expectation.fulfill()
            }
        }
        
        struct MockWeatherData: Codable {
            let weather: [Weather]
            let main: Main
            let name: String
            let timezone: Int
            
            struct Weather: Codable {
                let id: Int
            }
            
            struct Main: Codable {
                let temp: Double
            }
        }
        
        // Creating swift object et encode JSON
        let mockWeatherData = MockWeatherData(
            weather: [MockWeatherData.Weather(id: 802)],
            main: MockWeatherData.Main(temp: 18.0),
            name: "New York",
            timezone: -14400
        )
        
        
        let encoder = JSONEncoder()
        let mockJSON = try! encoder.encode(mockWeatherData)
        
        let mockSession = SessionMock(data: mockJSON)
        let mockDelegate = MockDelegate(expectation: expectation)
        
        var weatherManager = WeatherManager(session: mockSession)
        weatherManager.delegate = mockDelegate
        
        // Create WeatherModelNy with mockdatas
        let weatherNy = WeatherModelNy(conditionId: mockWeatherData.weather[0].id, townName: mockWeatherData.name,
                                       temperature: mockWeatherData.main.temp,
                                       timezone: mockWeatherData.timezone)
        
        // Call for direct delegate with mockeddata
        mockDelegate.didUpdateNyWeather(weatherManager, weather: weatherNy)
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertTrue(mockDelegate.didUpdateNyWeatherCalled, "The delegate's didUpdateNyWeather method should be called.")
        XCTAssertEqual(mockDelegate.receivedWeather?.townName, "New York", "The town name should match the mock JSON.")
        XCTAssertEqual(mockDelegate.receivedWeather?.temperature, 18.0, "The temperature should match the mock JSON.")
        XCTAssertEqual(mockDelegate.receivedWeather?.timezone, -14400, "The timezone should match the mock JSON.")
    }
}
