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

struct TranslateManager {
    let translateURL = "https://translation.googleapis.com/language/translate/v2?key=\(googleTranslateApiKey)"
    
    var delegate: TranslateManagerDelegate?
    
    func fetchTranslation(text: String, sourceLang: String, targetLang: String) {
        let urlString = "\(translateURL)&q=\(text)&source=\(sourceLang)&target=\(targetLang)"
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
                    if let translation = self.parseJSON(translateData: safeData) {
                        self.delegate?.didUpdateTranslation(self, translation: translation)
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
            let translatedText = decodedData.data.translations[0].translatedText
            let translation = TranslateModel(translatedText: translatedText)
            return translation
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
