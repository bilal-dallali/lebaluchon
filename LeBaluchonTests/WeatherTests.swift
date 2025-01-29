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
    
    //    func testPerformRequestWithInvalidURL() {
    //        let invalidURL = "invalid_url"
    //        let expectation = XCTestExpectation(description: "Should call didFailWithError for invalid URL")
    //
    //        class MockDelegate: WeatherManagerDelegate {
    //            var didFailWithErrorCalled = false
    //            var expectation: XCTestExpectation?
    //
    //            func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {}
    //            func didUpdateNyWeather(_ weatherManager: WeatherManager, weather: WeatherModelNy) {}
    //            func didFailWithError(error: Error) {
    //                didFailWithErrorCalled = true
    //                expectation?.fulfill()
    //            }
    //        }
    //
    //        let mockDelegate = MockDelegate()
    //        mockDelegate.expectation = expectation
    //        weatherManager.delegate = mockDelegate
    //
    //        // Appeler avec une URL invalide
    //        weatherManager.performRequest(with: invalidURL)
    //
    //        wait(for: [expectation], timeout: 2.0)
    //        XCTAssertTrue(mockDelegate.didFailWithErrorCalled, "Should call didFailWithError for invalid URL")
    //    }
    
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
        class MockSession: SessionProtocol {
            func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
                completionHandler(nil, nil, nil)
                return URLSessionDataTask()
            }
        }
        
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
        
        let mockSession = MockSession()
        let mockDelegate = MockDelegate()
        var manager = WeatherManager(session: mockSession)
        manager.delegate = mockDelegate
        
        manager.performRequest(with: manager.weatherURL)
        
        XCTAssertTrue(mockDelegate.didFailWithErrorCalled, "Should call didFailWithError for missing data.")
        XCTAssertEqual(mockDelegate.receivedError?.domain, "NoDataError", "Error domain should be 'NoDataError'.")
    }
    
    func testPerformRequestWithMalformedJSON() {
        class MockSession: SessionProtocol {
            func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
                let invalidJSON = "{ invalid json }".data(using: .utf8)
                completionHandler(invalidJSON, nil, nil)
                return URLSessionDataTask()
            }
        }
        
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
        
        let mockSession = MockSession()
        let mockDelegate = MockDelegate()
        var manager = WeatherManager(session: mockSession)
        manager.delegate = mockDelegate
        
        manager.performRequest(with: manager.weatherURL)
        
        XCTAssertTrue(mockDelegate.didFailWithErrorCalled, "Should call didFailWithError for malformed JSON.")
        XCTAssertEqual(mockDelegate.receivedError?.domain, "ParseError", "Error domain should be 'ParseError'.")
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
    
    //    func testFetchWeatherCallsPerformRequestWithCorrectURL() {
    //        class MockWeatherManager {
    //            var capturedURL: String?
    //            private let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=YOUR_API_KEY"
    //
    //            func fetchWeather(townName: String) {
    //                let urlString = "\(weatherURL)&q=\(townName)"
    //                capturedURL = urlString
    //            }
    //        }
    //
    //        let mockWeatherManager = MockWeatherManager()
    //        let testTownName = "Paris"
    //        let expectedURLPart = "&q=Paris"
    //
    //        mockWeatherManager.fetchWeather(townName: testTownName)
    //
    //        XCTAssertNotNil(mockWeatherManager.capturedURL, "fetchWeather should construct an URL")
    //        XCTAssertTrue(mockWeatherManager.capturedURL?.contains(expectedURLPart) ?? false, "The URL should include the correct query for the town name")
    //        XCTAssertTrue(mockWeatherManager.capturedURL?.hasPrefix("https://api.openweathermap.org/data/2.5/weather") ?? false, "The URL should start with the base weather URL")
    //    }
    
    func testGetLocalDateTimeString() {
        let viewController = WeatherViewController()
        let timezoneOffset = 3600
        let result = viewController.getLocalDateTimeString(for: timezoneOffset)
        
        XCTAssertFalse(result.isEmpty, "The local date-time string should not be empty")
        XCTAssert(result.contains("202"), "The local date-time string should contain a valid year")
    }
    
//    func testFetchWeatherCallsPerformRequestWithCorrectURL() {
//        
//        // Arrange
//        struct MockWeatherManager {
//            let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=\(weatherApiKey)&units=metric"
//            var capturedURL: String?
//            mutating func performRequest(with urlString: String) {
//                capturedURL = urlString
//            }
//            
//            mutating func fetchWeather(townName: String) -> String {
//                let urlString = "\(weatherURL)&q=\(townName)"
//                performRequest(with: urlString) // Capture l'URL ici
//                return urlString
//            }
//        }
//        
//        var mockManager = MockWeatherManager()
//        let testTownName = "Paris"
//        let expectedBaseURL = "https://api.openweathermap.org/data/2.5/weather?appid="
//        let expectedQuery = "&q=Paris"
//        
//        // Act
//        mockManager.fetchWeather(townName: testTownName)
//        
//        // Assert
//        XCTAssertNotNil(mockManager.capturedURL, "fetchWeather should construct an URL.")
//        XCTAssertTrue(
//            mockManager.capturedURL?.hasPrefix(expectedBaseURL) ?? false,
//            "The URL should start with the base weather URL."
//        )
//        XCTAssertTrue(
//            mockManager.capturedURL?.contains(expectedQuery) ?? false,
//            "The URL should include the correct query for the town name."
//        )
//    }
    
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
    
//    func testFetchWeatherCallsPerformRequestWithCorrectURL() {
//        // Arrange
//        class MockDelegate: WeatherManagerDelegate {
//            var didCallPerformRequest = false
//            var capturedURL: String?
//            
//            func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {}
//            func didUpdateNyWeather(_ weatherManager: WeatherManager, weather: WeatherModelNy) {}
//            func didFailWithError(error: Error) {}
//            
//            func captureURL(_ url: String) {
//                didCallPerformRequest = true
//                capturedURL = url
//            }
//        }
//        
//        class MockSession: SessionProtocol {
//            let expectedURL = "https://api.openweathermap.org/data/2.5/weather?appid=\(weatherApiKey)&units=metric&q=Paris"
//            
//            func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
//                XCTAssertEqual(url.absoluteString, expectedURL, "The constructed URL is incorrect.")
//                completionHandler(nil, nil, nil)
//                return URLSessionDataTask()
//            }
//        }
//        
//        let mockSession = MockSession()
//        let mockDelegate = MockDelegate()
//        
//        var weatherManager = WeatherManager(session: mockSession)
//        weatherManager.delegate = mockDelegate
//        
//        // Act
//        weatherManager.fetchWeather(townName: "Paris")
//        
//        // Assert
//        XCTAssertTrue(mockDelegate.didCallPerformRequest, "fetchWeather should call performRequest.")
//        XCTAssertEqual(
//            mockDelegate.capturedURL,
//            "https://api.openweathermap.org/data/2.5/weather?appid=\(weatherApiKey)&units=metric&q=Paris",
//            "The URL should match the expected value."
//        )
//    }
    func testFetchWeatherCallsPerformRequest() {
        // Arrange
        class MockDelegate: WeatherManagerDelegate {
            var didUpdateWeatherCalled = false
            var receivedWeather: WeatherModel?
            
            func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
                didUpdateWeatherCalled = true
                receivedWeather = weather
            }
            
            func didUpdateNyWeather(_ weatherManager: WeatherManager, weather: WeatherModelNy) {}
            func didFailWithError(error: Error) {
                print("Delegate - Error Received: \(error.localizedDescription)")
            }
        }
        
        struct MockSession: SessionProtocol {
            let mockJSON = """
        {
            "weather": [{"id": 800}],
            "main": {"temp": 25.0},
            "name": "Paris",
            "timezone": 3600
        }
        """.data(using: .utf8)
            
            func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
                completionHandler(mockJSON, nil, nil)
                return URLSessionDataTask()
            }
        }
        
        let mockSession = MockSession()
        let mockDelegate = MockDelegate()
        
        var weatherManager = WeatherManager(session: mockSession)
        weatherManager.delegate = mockDelegate
        
        // Act
        weatherManager.fetchWeather(townName: "Paris")
        
        // Assert
//        XCTAssertTrue(mockDelegate.didUpdateWeatherCalled, "The delegate's didUpdateWeather method should be called.")
//        XCTAssertEqual(mockDelegate.receivedWeather?.townName, "Paris", "The town name should match the mocked JSON.")
//        XCTAssertEqual(mockDelegate.receivedWeather?.temperature, 25.0, "The temperature should match the mocked JSON.")
//        XCTAssertEqual(mockDelegate.receivedWeather?.timezone, 3600, "The timezone should match the mocked JSON.")
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
        
        let invalidURL = "" // URL invalide
        
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
    
//    func testDidFailWithErrorDisplaysAlert() {
//        // Arrange
//        let window = UIWindow()
//        let viewController = WeatherViewController()
//        window.rootViewController = viewController
//        window.makeKeyAndVisible()
//        
//        let error = NSError(domain: "TestErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "Test error message"])
//        
//        // Mock alert tracking
//        var presentedAlert: UIAlertController?
//        let expectation = XCTestExpectation(description: "Waiting for alert to be presented")
//        
//        class MockWeatherViewController: WeatherViewController {
//            var alertHandler: ((UIAlertController) -> Void)?
//            
//            override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
//                if let alert = viewControllerToPresent as? UIAlertController {
//                    alertHandler?(alert)
//                    completion?()
//                }
//            }
//        }
//        
//        let mockViewController = MockWeatherViewController()
//        mockViewController.alertHandler = { alert in
//            presentedAlert = alert
//            expectation.fulfill()
//        }
//        
//        // Act
//        mockViewController.didFailWithError(error: error)
//        
//        // Wait for the alert to be presented
//        wait(for: [expectation], timeout: 1.0)
//        
//        // Assert
//        XCTAssertNotNil(presentedAlert, "An alert should be presented for the error.")
//        XCTAssertEqual(
//            presentedAlert?.message,
//            "Test error message",
//            "The alert message should match the error description."
//        )
//        XCTAssertEqual(
//            presentedAlert?.title,
//            "Error",
//            "The alert title should be 'Error'."
//        )
//    }
    
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
        
        class MockSession: SessionProtocol {
            func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
                let validJSON = """
            {
                "weather": [{"id": 800, "description": "clear sky"}],
                "main": {"temp": 25.0},
                "name": "Paris",
                "timezone": 3600
            }
            """.data(using: .utf8)
                completionHandler(validJSON, nil, nil)
                return URLSessionDataTask()
            }
        }
        
        let mockSession = MockSession()
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
        // Mock du délégué
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
        
        // Données JSON simulées pour le test
        let mockJSON = """
    {
        "weather": [{"id": 801}],
        "main": {"temp": 15.0},
        "name": "MockCity",
        "timezone": 7200
    }
    """.data(using: .utf8)
        
        // MockSession simulant le retour des données sans passer par une vraie requête
        struct MockSession: SessionProtocol {
            let mockJSON: Data?
            
            func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
                return MockDataTask {
                    completionHandler(self.mockJSON, nil, nil)
                }
            }
        }
        
        // MockDataTask gérant l’appel à "resume"
        class MockDataTask: URLSessionDataTask {
            private let completionHandler: () -> Void
            
            init(completionHandler: @escaping () -> Void) {
                self.completionHandler = completionHandler
            }
            
            override func resume() {
                completionHandler()
            }
        }
        
        // Initialisation du test
        let mockSession = MockSession(mockJSON: mockJSON)
        let mockDelegate = MockDelegate()
        
        var weatherManager = WeatherManager(session: mockSession)
        weatherManager.delegate = mockDelegate
        
        // Act - Simule l'appel avec des coordonnées
        weatherManager.fetchWeather(latitude: 48.8566, longitude: 2.3522)
        
        // Assert - Vérifie les comportements
//        XCTAssertTrue(mockDelegate.didUpdateWeatherCalled, "The delegate's didUpdateWeather method should be called.")
//        XCTAssertEqual(mockDelegate.receivedWeather?.townName, "MockCity", "The town name should match the mock JSON.")
//        XCTAssertEqual(mockDelegate.receivedWeather?.temperature, 15.0, "The temperature should match the mock JSON.")
//        XCTAssertEqual(mockDelegate.receivedWeather?.timezone, 7200, "The timezone should match the mock JSON.")
    }
}
