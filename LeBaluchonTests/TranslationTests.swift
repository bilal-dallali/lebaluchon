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
    
    func testPerformRequestWithLocalData() {
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
        
        // Initialisation de TranslateManager
        var manager = TranslateManager()
        manager.delegate = self
        
        // Simuler la logique de performRequest avec les données locales
        if let translation = manager.parseJSON(translateData: mockJSON) {
            didUpdateTranslation(manager, translation: translation)
        } else {
            let parsingError = NSError(domain: "ParseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse JSON"])
            didFailWithError(error: parsingError)
        }
        
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
