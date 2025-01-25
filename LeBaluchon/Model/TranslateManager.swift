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
    let translateURL = "https://translation.googleapis.com/language/translate/v2?key=\(googleTranslateApiKey)"
    
    var delegate: TranslateManagerDelegate?
    
    // Get translation
    func fetchTranslation(text: String, targetLang: String) {
        let urlString = "\(translateURL)&q=\(text)&target=\(targetLang)"
        performRequest(with: urlString)
    }
    
    // DO the right request
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let translation = self.parseJSON(translateData: safeData) {
                        self.delegate?.didUpdateTranslation(self, translation: translation)
                    } else {
                        let parsingError = NSError(domain: "ParseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse JSON"])
                        delegate?.didFailWithError(error: parsingError)
                    }
                }
            }
            task.resume()
        }
    }
    
    // Parse JSON
    func parseJSON(translateData: Data) -> TranslateModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(TranslateData.self, from: translateData)
            
            // Chek if the translation exist
            guard let firstTranslation = decodedData.data.translations.first else {
                let error = NSError(domain: "TranslationError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No translations found in JSON."])
                delegate?.didFailWithError(error: error)
                return nil
            }
            
            // Get the translated text
            let translatedText = firstTranslation.translatedText.htmlDecoded()
            
            // Get language if available
            let detectedSourceLanguage = firstTranslation.detectedSourceLanguage
            
            // Create and return model
            let translation = TranslateModel(translatedText: translatedText, detectedSourceLanguage: detectedSourceLanguage)
            return translation
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
    
}
