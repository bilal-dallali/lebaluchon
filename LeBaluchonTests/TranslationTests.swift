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
    
    override func setUpWithError() throws {
        translateManager = TranslateManager()
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
        var manager = TranslateManager()
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
    
    // Méthodes du délégué pour capturer les résultats
    func didUpdateTranslation(_ translateManager: TranslateManager, translation: TranslateModel) {
        receivedTranslation = translation
    }
    
    func didFailWithError(error: Error) {
        receivedError = error
        XCTFail("Erreur lors de la requête : \(error.localizedDescription)")
    }
}
