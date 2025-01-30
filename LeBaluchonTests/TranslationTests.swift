//
//  TranslationTests.swift
//  LeBaluchonTests
//
//  Created by Bilal Dallali on 12/01/2025.
//

import XCTest
@testable import LeBaluchon

final class TranslationTests: XCTestCase, TranslateManagerDelegate {
    
    var translateManager: TranslateManager!
    var viewController: TranslateViewController!
    
    override func setUpWithError() throws {
        translateManager = TranslateManager()
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        XCTAssertNotNil(storyboard, "Le storyboard Main n'a pas pu être chargé.")
        
        viewController = storyboard.instantiateViewController(withIdentifier: "TranslateViewController") as? TranslateViewController
        
        XCTAssertNotNil(viewController, "Le contrôleur TranslateViewController n'a pas pu être instancié depuis le storyboard.")
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        
        viewController.loadViewIfNeeded()
    }
    
    override func tearDownWithError() throws {
        translateManager = nil
    }
    
    func testParseJSONValidData() throws {
        let json = """
        {
            "data": {
                "translations": [
                    {
                        "translatedText": "Bonjour le monde"
                    }
                ]
            }
        }
        """.data(using: .utf8)!
        
        let translation = translateManager.parseJSON(translateData: json)
        
        XCTAssertNotNil(translation, "TranslateModel should not be nil for valid JSON")
        XCTAssertEqual(translation?.translatedText, "Bonjour le monde", "Translated text does not match")
    }
    
    func testParseJSONInvalidData() throws {
        let json = """
        {
            "invalidKey": {
                "translations": [
                    {
                        "translatedText": "Bonjour le monde"
                    }
                ]
            }
        }
        """.data(using: .utf8)!
        
        let translation = translateManager.parseJSON(translateData: json)
        
        XCTAssertNil(translation, "TranslateModel should be nil for invalid JSON")
    }
    
    func testParseJSONMissingTranslations() throws {
        let json = """
        {
            "data": {
                "translations": []
            }
        }
        """.data(using: .utf8)!
        
        let translation = translateManager.parseJSON(translateData: json)
        
        XCTAssertNil(translation, "TranslateModel should be nil when translations array is empty")
    }
    
    func testLanguageDetection() {
        let jsonData = """
        {
            "data": {
                "translations": [
                    {
                        "translatedText": "Ich gehe ins Kino",
                        "detectedSourceLanguage": "en"
                    }
                ]
            }
        }
        """.data(using: .utf8)!
        
        let manager = TranslateManager()
        let result = manager.parseJSON(translateData: jsonData)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.detectedSourceLanguage, "en")
    }
    
    var expectation: XCTestExpectation!
    var receivedTranslation: TranslateModel?
    var receivedError: Error?
    
    func testPerformRequestWithLocalFile() {
        // Données JSON simulées pour le test
        let mockJSON = """
        {
            "data": {
                "translations": [
                    {
                        "translatedText": "Hello",
                        "detectedSourceLanguage": "fr"
                    }
                ]
            }
        }
        """.data(using: .utf8)!
        
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempFileURL = tempDirectory.appendingPathComponent("mockResponse.json")
        try! mockJSON.write(to: tempFileURL)
        
        
        // Init translatemanager
        var manager = TranslateManager(session: SessionMock(data: mockJSON))
        manager.delegate = self
        
        // Call performrequest with localurl
        manager.performRequest(with: tempFileURL.absoluteString)
        
        // wait for result return
        let expectation = self.expectation(description: "Waiting for performRequest completion")
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) { expectation.fulfill() }
        waitForExpectations(timeout: 2)
        
        // Check
        XCTAssertNotNil(receivedTranslation, "La traduction devrait être non nulle.")
        XCTAssertEqual(receivedTranslation?.translatedText, "Hello", "Le texte traduit est incorrect.")
        XCTAssertEqual(receivedTranslation?.detectedSourceLanguage, "fr", "La langue détectée est incorrecte.")
    }
    
    func testPerformRequestWithInvalidURL() {
        let expectation = XCTestExpectation(description: "Should call didFailWithError for invalid URL")
        
        // Mock delegate
        class MockDelegate: TranslateManagerDelegate {
            var didFailWithErrorCalled = false
            var receivedError: NSError?
            let expectation: XCTestExpectation
            
            init(expectation: XCTestExpectation) {
                self.expectation = expectation
            }
            
            func didUpdateTranslation(_ translateManager: TranslateManager, translation: TranslateModel) {}
            
            func didFailWithError(error: Error) {
                didFailWithErrorCalled = true
                receivedError = error as NSError
                expectation.fulfill()
            }
        }
        
        // Use URL invalid
        let invalidURL = ""
        
        // Sessionmock to avoid network call
        let mockSession = SessionMock()
        let mockDelegate = MockDelegate(expectation: expectation)
        
        var translateManager = TranslateManager(session: mockSession)
        translateManager.delegate = mockDelegate
        
        // Act execute request with invalid URL
        translateManager.performRequest(with: invalidURL)
        
        // Wait for simulated response
        wait(for: [expectation], timeout: 1.0)
        
        // Assert - checking errors
        XCTAssertTrue(mockDelegate.didFailWithErrorCalled, "Should call didFailWithError for invalid URL.")
        XCTAssertEqual(mockDelegate.receivedError?.domain, "InvalidURLError", "Error domain should be 'InvalidURLError'.")
        XCTAssertEqual(mockDelegate.receivedError?.localizedDescription, "The URL is invalid.", "Error message should indicate invalid URL.")
    }
    
    func testPerformRequestWithNoData() {
        let expectation = XCTestExpectation(description: "Should call didFailWithError when no data is received")
        
        // Mock delegate
        class MockDelegate: TranslateManagerDelegate {
            var didFailWithErrorCalled = false
            var receivedError: NSError?
            let expectation: XCTestExpectation
            
            init(expectation: XCTestExpectation) {
                self.expectation = expectation
            }
            
            func didUpdateTranslation(_ translateManager: TranslateManager, translation: TranslateModel) {}
            
            func didFailWithError(error: Error) {
                didFailWithErrorCalled = true
                receivedError = error as NSError
                expectation.fulfill()
            }
        }
        
        // Using SessionMock to send nil for data
        class SessionMockNoData: SessionProtocol {
            func perform(url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
                completionHandler(nil, nil, nil)
            }
        }
        
        let mockSession = SessionMockNoData()
        let mockDelegate = MockDelegate(expectation: expectation)
        
        var translateManager = TranslateManager(session: mockSession)
        translateManager.delegate = mockDelegate
        
        // Act - Execute request
        translateManager.performRequest(with: "https://mockurl.com")
        
        // Wait for simulated response
        wait(for: [expectation], timeout: 1.0)
        
        // Assert - Checking errors
        XCTAssertTrue(mockDelegate.didFailWithErrorCalled, "Should call didFailWithError when no data is received.")
        XCTAssertEqual(mockDelegate.receivedError?.domain, "NoDataError", "Error domain should be 'NoDataError'.")
        XCTAssertEqual(mockDelegate.receivedError?.localizedDescription, "No data returned from server.", "Error message should indicate no data received.")
    }
    
    func testPerformRequestWithMalformedJSON() {
        let expectation = XCTestExpectation(description: "Should call didFailWithError for malformed JSON")
        
        // Mock delegate
        class MockDelegate: TranslateManagerDelegate {
            var didFailWithErrorCalled = false
            var receivedError: NSError?
            let expectation: XCTestExpectation
            
            init(expectation: XCTestExpectation) {
                self.expectation = expectation
            }
            
            func didUpdateTranslation(_ translateManager: TranslateManager, translation: TranslateModel) {}
            
            func didFailWithError(error: Error) {
                didFailWithErrorCalled = true
                receivedError = error as NSError
                expectation.fulfill()
            }
        }
        
        // Malformed JSON for parsing errors
        let invalidJSON = "{ invalid json }".data(using: .utf8)
        
        // Session mock for malformed JSON
        class SessionMockWithMalformedJSON: SessionProtocol {
            let mockJSON: Data?
            
            init(mockJSON: Data?) {
                self.mockJSON = mockJSON
            }
            
            func perform(url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
                completionHandler(self.mockJSON, nil, nil) // Retourne un JSON invalide
            }
        }
        
        // Configuration
        let mockSession = SessionMockWithMalformedJSON(mockJSON: invalidJSON)
        let mockDelegate = MockDelegate(expectation: expectation)
        
        var translateManager = TranslateManager(session: mockSession)
        translateManager.delegate = mockDelegate
        
        // Act - Execute request
        translateManager.performRequest(with: "https://mockurl.com")
        
        // Wait for simulated response
        wait(for: [expectation], timeout: 1.0)
        
        // Assert - Checking
        XCTAssertTrue(mockDelegate.didFailWithErrorCalled, "Should call didFailWithError for malformed JSON.")
        XCTAssertEqual(mockDelegate.receivedError?.domain, "ParseError", "Error domain should be 'ParseError'.")
        XCTAssertEqual(mockDelegate.receivedError?.localizedDescription, "Failed to parse JSON.", "Error message should indicate JSON parsing failure.")
    }
    
    func testPerformRequestWithNetworkError() {
        let expectation = XCTestExpectation(description: "Should call didFailWithError for network error")
        
        // Mock delegate
        class MockDelegate: TranslateManagerDelegate {
            var didFailWithErrorCalled = false
            var receivedError: NSError?
            let expectation: XCTestExpectation
            
            init(expectation: XCTestExpectation) {
                self.expectation = expectation
            }
            
            func didUpdateTranslation(_ translateManager: TranslateManager, translation: TranslateModel) {}
            
            func didFailWithError(error: Error) {
                didFailWithErrorCalled = true
                receivedError = error as NSError
                expectation.fulfill()
            }
        }
        
        // Error simulated network
        let networkError = NSError(domain: "NetworkError", code: -1001, userInfo: [NSLocalizedDescriptionKey: "Network request failed."])
        
        // Mock session for network error
        class SessionMockWithError: SessionProtocol {
            let simulatedError: NSError
            
            init(error: NSError) {
                self.simulatedError = error
            }
            
            func perform(url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
                completionHandler(nil, nil, simulatedError)
            }
        }
        
        // Configurate test
        let mockSession = SessionMockWithError(error: networkError)
        let mockDelegate = MockDelegate(expectation: expectation)
        
        var translateManager = TranslateManager(session: mockSession)
        translateManager.delegate = mockDelegate
        
        // Act - Execute request
        translateManager.performRequest(with: "https://mockurl.com")
        
        // Wait for simulated response
        wait(for: [expectation], timeout: 1.0)
        
        // Assert - Check errors
        XCTAssertTrue(mockDelegate.didFailWithErrorCalled, "Should call didFailWithError for network error.")
        XCTAssertEqual(mockDelegate.receivedError?.domain, "NetworkError", "Error domain should be 'NetworkError'.")
        XCTAssertEqual(mockDelegate.receivedError?.localizedDescription, "Network request failed.", "Error message should indicate network failure.")
    }
    
    func testFetchTranslationCallsPerformRequestWithCorrectURL() {
        let expectation = XCTestExpectation(description: "Translation request should be made")
        
        class MockDelegate: TranslateManagerDelegate {
            var didUpdateTranslationCalled = false
            var receivedTranslation: TranslateModel?
            let expectation: XCTestExpectation
            
            init(expectation: XCTestExpectation) {
                self.expectation = expectation
            }
            
            func didUpdateTranslation(_ translateManager: TranslateManager, translation: TranslateModel) {
                didUpdateTranslationCalled = true
                receivedTranslation = translation
                expectation.fulfill()
            }
            
            func didFailWithError(error: Error) {
                XCTFail("didFailWithError should not be called in this test.")
            }
        }
        
        let mockJSON = """
    {
        "data": {
            "translations": [
                { "translatedText": "Bonjour", "detectedSourceLanguage": "en" }
            ]
        }
    }
    """.data(using: .utf8)
        
        let mockSession = SessionMock(data: mockJSON)
        let mockDelegate = MockDelegate(expectation: expectation)
        
        var translateManager = TranslateManager(session: mockSession)
        translateManager.delegate = mockDelegate
        
        translateManager.fetchTranslation(text: "Hello", targetLang: "fr")
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertTrue(mockDelegate.didUpdateTranslationCalled, "The delegate's didUpdateTranslation method should be called.")
        XCTAssertEqual(mockDelegate.receivedTranslation?.translatedText, "Bonjour", "The translated text should match the mocked response.")
        XCTAssertEqual(mockDelegate.receivedTranslation?.detectedSourceLanguage, "en", "The detected language should match the mocked response.")
    }
    
    // Delegate method to check results
    func didUpdateTranslation(_ translateManager: TranslateManager, translation: TranslateModel) {
        receivedTranslation = translation
    }
    
    func didFailWithError(error: Error) {
        receivedError = error
        XCTFail("Erreur lors de la requête : \(error.localizedDescription)")
    }
}
