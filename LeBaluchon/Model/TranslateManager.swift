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
    
    func fetchTranslation(text: String, targetLang: String) {
        let urlString = "\(translateURL)&q=\(text)&target=\(targetLang)"
        //\(translateURL)&q=\(text)&target=fr
        print("fetch translation")
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let jsonString = String(data: safeData, encoding: .utf8) {
                        print("JSON Response: \(jsonString)")
                    }
                    if let translation = self.parseJSON(translateData: safeData) {
                        self.delegate?.didUpdateTranslation(self, translation: translation)
                    }
                    if let detectedLanguage = self.parseJSON(translateData: safeData) {
                        print("Detected Language: \(detectedLanguage)")
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(translateData: Data) -> TranslateModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(TranslateData.self, from: translateData)
            
            // Vérifiez que les traductions existent
            guard let firstTranslation = decodedData.data.translations.first else {
                let error = NSError(domain: "TranslationError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No translations found in JSON."])
                delegate?.didFailWithError(error: error)
                return nil
            }
            
            // Récupérez le texte traduit
            let translatedText = firstTranslation.translatedText.htmlDecoded()
            
            // Récupérez la langue détectée (si disponible)
            let detectedSourceLanguage = firstTranslation.detectedSourceLanguage
            print("Detected Source Language: \(detectedSourceLanguage ?? "Unknown")")
            
            // Créez et retournez le modèle
            let translation = TranslateModel(translatedText: translatedText, detectedSourceLanguage: detectedSourceLanguage)
            return translation
        } catch {
            delegate?.didFailWithError(error: error)
            print("Error parsing JSON: \(error.localizedDescription)")
            return nil
        }
    }
    
    func fetchDetectedLanguage(text: String) {
        let urlString = "\(translateURL)&q=\(text)&target=fr"
        performLanguageDetectionRequest(with: urlString)
    }
    
    private func performLanguageDetectionRequest(with urlString: String) {
        print("Test900")
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let jsonString = String(data: safeData, encoding: .utf8) {
                        print("JSON Response: \(jsonString)")
                    }
                    if let detectedLanguage = self.parseLanguageDetectionJSON(data: safeData) {
                        print("Detected Language: \(detectedLanguage)")
                    }
                }
            }
            task.resume()
        }
    }
    
    private func parseLanguageDetectionJSON(data: Data) -> String? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(LanguageDetectionData.self, from: data)
            let detectedLanguage = decodedData.data.detections.first?.language
            return detectedLanguage
        } catch {
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
