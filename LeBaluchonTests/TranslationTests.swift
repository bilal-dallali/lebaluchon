//
//  TranslationTests.swift
//  LeBaluchonTests
//
//  Created by Bilal Dallali on 12/01/2025.
//

import XCTest
@testable import LeBaluchon

final class TranslationTests: XCTestCase {
    
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
}
