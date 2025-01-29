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
        
        // Charger le ViewController depuis le storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        // Vérifiez que le storyboard est chargé
        XCTAssertNotNil(storyboard, "Le storyboard Main n'a pas pu être chargé.")
        
        viewController = storyboard.instantiateViewController(withIdentifier: "TranslateViewController") as? TranslateViewController
        
        // Vérifiez que viewController est instancié
        XCTAssertNotNil(viewController, "Le contrôleur TranslateViewController n'a pas pu être instancié depuis le storyboard.")
        
        // Attacher à une fenêtre
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        
        // Forcer le chargement de la vue
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
        
        // Créer un fichier temporaire pour stocker les données simulées
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempFileURL = tempDirectory.appendingPathComponent("mockResponse.json")
        try! mockJSON.write(to: tempFileURL)
        
        
        // Initialisation de TranslateManager
        var manager = TranslateManager(session: SessionMock(data: mockJSON))
        manager.delegate = self
        
        // Appeler performRequest avec l'URL locale (chemin du fichier)
        manager.performRequest(with: tempFileURL.absoluteString)
        
        // Attendre que les résultats soient retournés
        let expectation = self.expectation(description: "Waiting for performRequest completion")
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) { expectation.fulfill() }
        waitForExpectations(timeout: 2)
        
        // Vérifications
        XCTAssertNotNil(receivedTranslation, "La traduction devrait être non nulle.")
        XCTAssertEqual(receivedTranslation?.translatedText, "Hello", "Le texte traduit est incorrect.")
        XCTAssertEqual(receivedTranslation?.detectedSourceLanguage, "fr", "La langue détectée est incorrecte.")
    }
    
    func testPerformRequestWithInvalidURL() {
        let expectation = XCTestExpectation(description: "Should call didFailWithError for invalid URL")
        
        // Mock du délégué
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
        
        // Utilisation d'un URL **totalement invalide** (ex : une chaîne vide)
        let invalidURL = ""
        
        // SessionMock pour éviter un appel réseau réel
        let mockSession = SessionMock()
        let mockDelegate = MockDelegate(expectation: expectation)
        
        var translateManager = TranslateManager(session: mockSession)
        translateManager.delegate = mockDelegate
        
        // Act - Exécution de la requête avec un URL invalide
        translateManager.performRequest(with: invalidURL)
        
        // Attente de la réponse simulée
        wait(for: [expectation], timeout: 1.0)
        
        // Assert - Vérification des erreurs
        XCTAssertTrue(mockDelegate.didFailWithErrorCalled, "Should call didFailWithError for invalid URL.")
        XCTAssertEqual(mockDelegate.receivedError?.domain, "InvalidURLError", "Error domain should be 'InvalidURLError'.")
        XCTAssertEqual(mockDelegate.receivedError?.localizedDescription, "The URL is invalid.", "Error message should indicate invalid URL.")
    }
    
    func testPerformRequestWithNoData() {
        let expectation = XCTestExpectation(description: "Should call didFailWithError when no data is received")
        
        // Mock du délégué
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
        
        // Utilisation de `SessionMock` qui renvoie `nil` pour `data`
        class SessionMockNoData: SessionProtocol {
            func perform(url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
                completionHandler(nil, nil, nil) // Simule une réponse sans données ni erreur
            }
        }
        
        let mockSession = SessionMockNoData()
        let mockDelegate = MockDelegate(expectation: expectation)
        
        var translateManager = TranslateManager(session: mockSession)
        translateManager.delegate = mockDelegate
        
        // Act - Exécution de la requête
        translateManager.performRequest(with: "https://mockurl.com") // Peu importe l'URL, on simule l'absence de données
        
        // Attente de la réponse simulée
        wait(for: [expectation], timeout: 1.0)
        
        // Assert - Vérification des erreurs
        XCTAssertTrue(mockDelegate.didFailWithErrorCalled, "Should call didFailWithError when no data is received.")
        XCTAssertEqual(mockDelegate.receivedError?.domain, "NoDataError", "Error domain should be 'NoDataError'.")
        XCTAssertEqual(mockDelegate.receivedError?.localizedDescription, "No data returned from server.", "Error message should indicate no data received.")
    }
    
    func testPerformRequestWithMalformedJSON() {
        let expectation = XCTestExpectation(description: "Should call didFailWithError for malformed JSON")
        
        // Mock du délégué
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
        
        // JSON malformé pour forcer une erreur de parsing
        let invalidJSON = "{ invalid json }".data(using: .utf8)
        
        // Mock de la session qui retourne un JSON malformé
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
        
        // Act - Exécution de la requête
        translateManager.performRequest(with: "https://mockurl.com")
        
        // Attente de la réponse simulée
        wait(for: [expectation], timeout: 1.0)
        
        // Assert - Vérification des erreurs
        XCTAssertTrue(mockDelegate.didFailWithErrorCalled, "Should call didFailWithError for malformed JSON.")
        XCTAssertEqual(mockDelegate.receivedError?.domain, "ParseError", "Error domain should be 'ParseError'.")
        XCTAssertEqual(mockDelegate.receivedError?.localizedDescription, "Failed to parse JSON.", "Error message should indicate JSON parsing failure.")
    }
    
    func testPerformRequestWithNetworkError() {
        let expectation = XCTestExpectation(description: "Should call didFailWithError for network error")
        
        // Mock du délégué
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
        
        // Erreur réseau simulée
        let networkError = NSError(domain: "NetworkError", code: -1001, userInfo: [NSLocalizedDescriptionKey: "Network request failed."])
        
        // Mock de la session qui retourne une erreur réseau
        class SessionMockWithError: SessionProtocol {
            let simulatedError: NSError
            
            init(error: NSError) {
                self.simulatedError = error
            }
            
            func perform(url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
                completionHandler(nil, nil, simulatedError)
            }
        }
        
        // Configuration du test
        let mockSession = SessionMockWithError(error: networkError)
        let mockDelegate = MockDelegate(expectation: expectation)
        
        var translateManager = TranslateManager(session: mockSession)
        translateManager.delegate = mockDelegate
        
        // Act - Exécution de la requête
        translateManager.performRequest(with: "https://mockurl.com")
        
        // Attente de la réponse simulée
        wait(for: [expectation], timeout: 1.0)
        
        // Assert - Vérification des erreurs
        XCTAssertTrue(mockDelegate.didFailWithErrorCalled, "Should call didFailWithError for network error.")
        XCTAssertEqual(mockDelegate.receivedError?.domain, "NetworkError", "Error domain should be 'NetworkError'.")
        XCTAssertEqual(mockDelegate.receivedError?.localizedDescription, "Network request failed.", "Error message should indicate network failure.")
    }
    
    // Méthodes du délégué pour capturer les résultats
    func didUpdateTranslation(_ translateManager: TranslateManager, translation: TranslateModel) {
        receivedTranslation = translation
    }
    
    func didFailWithError(error: Error) {
        receivedError = error
        XCTFail("Erreur lors de la requête : \(error.localizedDescription)")
    }
}
