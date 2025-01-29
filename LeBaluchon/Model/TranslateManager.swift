//
//  TranslateManager.swift
//  LeBaluchon
//
//  Created by Bilal D on 12/09/2024.
//

import Foundation

protocol TranslateManagerDelegate {
    func didUpdateTranslation(_ translateManager: TranslateManager, translation: TranslateModel)
    func didFailWithError(error: Error)
}


extension String {
    func htmlDecoded() -> String {
        guard let data = self.data(using: .utf8) else { return self }
        let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        return attributedString?.string ?? self
    }
}

struct TranslateManager {
    private let session: SessionProtocol
    let translateURL = "https://translation.googleapis.com/language/translate/v2?key=\(googleTranslateApiKey)"
    var delegate: TranslateManagerDelegate?
    
    init(session: SessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    func fetchTranslation(text: String, targetLang: String) {
        let urlString = "\(translateURL)&q=\(text)&target=\(targetLang)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "InvalidURLError", code: 0, userInfo: [NSLocalizedDescriptionKey: "The URL is invalid."])
            delegate?.didFailWithError(error: error)
            return
        }
        
        session.perform(url: url) { data, response, error in
            if let error = error {
                self.delegate?.didFailWithError(error: error)
                return
            }
            
            guard let safeData = data else {
                let error = NSError(domain: "NoDataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data returned from server."])
                self.delegate?.didFailWithError(error: error)
                return
            }
            
            if let translation = self.parseJSON(translateData: safeData) {
                self.delegate?.didUpdateTranslation(self, translation: translation)
            } else {
                let parsingError = NSError(domain: "ParseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse JSON."])
                delegate?.didFailWithError(error: parsingError)
            }
        }
    }
    
    func parseJSON(translateData: Data) -> TranslateModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(TranslateData.self, from: translateData)
            
            guard let firstTranslation = decodedData.data.translations.first else {
                let error = NSError(domain: "TranslationError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No translations found in JSON."])
                delegate?.didFailWithError(error: error)
                return nil
            }
            
            let translatedText = firstTranslation.translatedText.htmlDecoded()
            let detectedSourceLanguage = firstTranslation.detectedSourceLanguage
            
            return TranslateModel(translatedText: translatedText, detectedSourceLanguage: detectedSourceLanguage)
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
