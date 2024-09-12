//
//  CurrencyManager.swift
//  LeBaluchon
//
//  Created by Bilal D on 05/09/2024.
//

import Foundation

protocol CurrencyManagerDelegate {
    func didUpdateCurrency(_ currencyManager: CurrencyManager, currency: CurrencyModel)
    func didFailWithError(error: Error)
}

struct CurrencyManager {
    let currencyURL = "https://data.fixer.io/api/latest?access_key=\(currencyApiKey)&base=USD&symbols=EUR"
    
    var delegate: CurrencyManagerDelegate?
    
    func fetchCurrency() {
        let urlString = currencyURL
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
                    if let currency = self.parseJSON(currencyData: safeData) {
                        self.delegate?.didUpdateCurrency(self, currency: currency)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(currencyData: Data) -> CurrencyModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CurrencyData.self, from: currencyData)
            let rate = decodedData.rates["USD"]!
            let currency = CurrencyModel(exchangeRate: rate)
            return currency
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
