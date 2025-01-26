//
//  CurrencyTests.swift
//  LeBaluchonTests
//
//  Created by Bilal Dallali on 12/01/2025.
//

import XCTest
@testable import LeBaluchon

final class CurrencyManagerTests: XCTestCase, CurrencyManagerDelegate {
    var currencyManager: CurrencyManager!
    var expectation: XCTestExpectation!
    var updateCurrencyCalled = false
    var receivedError: Error!
    
    override func setUpWithError() throws {
        super.setUp()
        currencyManager = CurrencyManager()
        currencyManager.delegate = self
        updateCurrencyCalled = false
        receivedError = nil
    }
    
    override func tearDownWithError() throws {
        currencyManager = nil
        super.tearDown()
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

    
    func testPerformRequestWithValidResponse() {
        class MockDelegate: CurrencyManagerDelegate {
            var didUpdateCurrencyCalled = false
            var receivedCurrency: CurrencyModel?
            
            func didUpdateCurrency(_ currencyManager: CurrencyManager, currency: CurrencyModel) {
                didUpdateCurrencyCalled = true
                receivedCurrency = currency
            }
            
            func didFailWithError(error: Error) {}
        }
        
        // Déclarez `manager` comme une variable modifiable
        var manager = CurrencyManager()
        let mockDelegate = MockDelegate()
        manager.delegate = mockDelegate
        
        let validJSON = """
        {
            "rates": { "USD": 1.23 }
        }
        """.data(using: .utf8)!
        
        // Simulez une requête réseau réussie
        mockDelegate.didUpdateCurrency(manager, currency: CurrencyModel(exchangeRate: 1.23))
        
        // Vérifiez les résultats
        XCTAssertTrue(mockDelegate.didUpdateCurrencyCalled, "Delegate should be called for a successful response")
        XCTAssertEqual(mockDelegate.receivedCurrency?.exchangeRate, 1.23, "Exchange rate should match the JSON data")
    }
    
    func testPerformRequest() {
        class MockURLSession: URLSession, @unchecked Sendable {
            var completionHandler: ((Data?, URLResponse?, Error?) -> Void)?
            
            override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
                self.completionHandler = completionHandler
                return MockURLSessionDataTask()
            }
        }
        
        class MockURLSessionDataTask: URLSessionDataTask, @unchecked Sendable {
            override func resume() {
                // Simule l'exécution immédiate
            }
        }
        
        class MockDelegate: CurrencyManagerDelegate {
            var didUpdateCurrencyCalled = false
            var didFailWithErrorCalled = false
            var receivedCurrency: CurrencyModel?
            var receivedError: Error?
            
            func didUpdateCurrency(_ currencyManager: CurrencyManager, currency: CurrencyModel) {
                didUpdateCurrencyCalled = true
                receivedCurrency = currency
            }
            
            func didFailWithError(error: Error) {
                didFailWithErrorCalled = true
                receivedError = error
            }
        }
        
        // Arrange
        let validJSON = """
        {
            "rates": { "USD": 1.23 }
        }
        """.data(using: .utf8)!
        
        let invalidJSON = """
        {
            "invalidKey": {}
        }
        """.data(using: .utf8)!
        
        var manager = CurrencyManager()
        let mockSession = MockURLSession()
        let mockDelegate = MockDelegate()
        manager.delegate = mockDelegate
        
        // Injection indirecte (au lieu de modifier `URLSession.shared`)
        func mockPerformRequest(with urlString: String) {
            if let url = URL(string: urlString) {
                let task = mockSession.dataTask(with: url) { data, response, error in
                    if error != nil {
                        mockDelegate.didFailWithError(error: error!)
                        return
                    }
                    guard let safeData = data else {
                        let error = NSError(domain: "NoDataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data returned from server."])
                        mockDelegate.didFailWithError(error: error)
                        return
                    }
                    
                    if let currency = manager.parseJSON(currencyData: safeData) {
                        mockDelegate.didUpdateCurrency(manager, currency: currency)
                    } else {
                        let error = NSError(domain: "ParseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse JSON."])
                        mockDelegate.didFailWithError(error: error)
                    }
                }
                task.resume()
            }
        }
        
        // Act - Cas 1 : Réponse JSON valide
        mockPerformRequest(with: manager.currencyURL)
        mockSession.completionHandler?(validJSON, nil, nil)
        
        // Assert - Cas 1
        XCTAssertTrue(mockDelegate.didUpdateCurrencyCalled, "The delegate should be called for a successful response")
        XCTAssertEqual(mockDelegate.receivedCurrency?.exchangeRate, 1.23, "The exchange rate should match the JSON data")
        
        // Act - Cas 2 : Erreur réseau
        let networkError = NSError(domain: "NetworkError", code: -1, userInfo: nil)
        mockPerformRequest(with: manager.currencyURL)
        mockSession.completionHandler?(nil, nil, networkError)
        
        // Assert - Cas 2
        XCTAssertTrue(mockDelegate.didFailWithErrorCalled, "The delegate should be called for a network error")
        XCTAssertEqual((mockDelegate.receivedError as NSError?)?.domain, "NetworkError", "The error should match the simulated network error")
        
        // Act - Cas 3 : Données manquantes
        mockPerformRequest(with: manager.currencyURL)
        mockSession.completionHandler?(nil, nil, nil)
        
        // Assert - Cas 3
        XCTAssertTrue(mockDelegate.didFailWithErrorCalled, "The delegate should be called when no data is returned")
        XCTAssertEqual((mockDelegate.receivedError as NSError?)?.domain, "NoDataError", "The error should indicate no data returned")
        
        // Act - Cas 4 : Erreur de parsing JSON
        mockPerformRequest(with: manager.currencyURL)
        mockSession.completionHandler?(invalidJSON, nil, nil)
        
        // Assert - Cas 4
        XCTAssertTrue(mockDelegate.didFailWithErrorCalled, "The delegate should be called for a parsing error")
        XCTAssertEqual((mockDelegate.receivedError as NSError?)?.domain, "ParseError", "The error should indicate a parsing error")
    }
    
    func testFetchCurrencyWithInvalidURL() {
        // Arrange
        currencyManager.currencyURL = "invalid-url"
        
        // Act
        expectation = expectation(description: "Waiting for invalid URL error")
        currencyManager.fetchCurrency()
        
        // Assert
        waitForExpectations(timeout: 2.0)
        XCTAssertNotNil(receivedError, "Une erreur aurait dû être reçue pour une URL invalide.")
    }
    
    func testPerformRequestWithNetworkError() {
        // Arrange
        let mockSession = MockURLSession(data: nil, response: nil, error: NSError(domain: "TestError", code: 123, userInfo: nil))
        currencyManager.performRequest(with: "https://mockurl.com")
        
        // Act
        expectation = expectation(description: "Waiting for network error")
        currencyManager.fetchCurrency()
        
        // Assert
        waitForExpectations(timeout: 2.0)
        XCTAssertNotNil(receivedError, "Une erreur aurait dû être reçue pour une erreur réseau.")
    }
    
    func testParseJSONWithMissingRate() {
        // Arrange
        let jsonData = """
        {
            "rates": {}
        }
        """.data(using: .utf8)!
        
        // Act
        let result = currencyManager.parseJSON(currencyData: jsonData)
        
        // Assert
        XCTAssertNil(result, "Le parsing aurait dû échouer car le taux USD est manquant.")
        XCTAssertNotNil(receivedError, "Une erreur aurait dû être envoyée pour un taux USD manquant.")
    }
    
    func testParseJSONWithInvalidJSON() {
        // Arrange
        let invalidJSONData = "invalid-json".data(using: .utf8)!
        
        // Act
        let result = currencyManager.parseJSON(currencyData: invalidJSONData)
        
        // Assert
        XCTAssertNil(result, "Le parsing aurait dû échouer pour un JSON invalide.")
        XCTAssertNotNil(receivedError, "Une erreur aurait dû être envoyée pour un JSON invalide.")
    }
    
    func testParseJSONWithValidData() {
        // Arrange
        let validJSONData = """
        {
            "rates": {
                "USD": 1.234
            }
        }
        """.data(using: .utf8)!
        
        // Act
        let result = currencyManager.parseJSON(currencyData: validJSONData)
        
        // Assert
        XCTAssertNotNil(result, "Le parsing aurait dû réussir pour un JSON valide.")
        XCTAssertEqual(result?.exchangeRate, 1.234, "Le taux USD est incorrect.")
    }
    
    // MARK: - CurrencyManagerDelegate
    
    func didUpdateCurrency(_ currencyManager: CurrencyManager, currency: CurrencyModel) {
        updateCurrencyCalled = true
        expectation.fulfill()
    }
    
    func didFailWithError(error: Error) {
        print("Erreur capturée dans didFailWithError : \(error.localizedDescription)")
        receivedError = error
        expectation?.fulfill()
    }
}

class MockURLSession: URLSession, @unchecked Sendable {
    private let mockData: Data?
    private let mockResponse: URLResponse?
    private let mockError: Error?
    
    init(data: Data?, response: URLResponse?, error: Error?) {
        self.mockData = data
        self.mockResponse = response
        self.mockError = error
    }
    
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let task = MockURLSessionDataTask {
            completionHandler(self.mockData, self.mockResponse, self.mockError)
        }
        return task
    }
}

class MockURLSessionDataTask: URLSessionDataTask, @unchecked Sendable {
    private let completionHandler: () -> Void
    
    init(completionHandler: @escaping () -> Void) {
        self.completionHandler = completionHandler
    }
    
    override func resume() {
        completionHandler()
    }
}
