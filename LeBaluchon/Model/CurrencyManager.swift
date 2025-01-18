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
    let currencyURL = "https://data.fixer.io/api/latest?access_key=\(currencyApiKey)&base=EUR&symbols=USD"
    
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
                guard let safeData = data else {
                    let error = NSError(domain: "NoDataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data returned from server."])
                    self.delegate?.didFailWithError(error: error)
                    return
                }
                
                if let currency = self.parseJSON(currencyData: safeData) {
                    self.delegate?.didUpdateCurrency(self, currency: currency)
                } else {
                    let error = NSError(domain: "ParseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse JSON."])
                    self.delegate?.didFailWithError(error: error)
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(currencyData: Data) -> CurrencyModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CurrencyData.self, from: currencyData)
            //let rate = decodedData.rates["USD"]!
            guard let rate = decodedData.rates["USD"] else {
                let error = NSError(domain: "MissingRateError", code: 0, userInfo: [NSLocalizedDescriptionKey: "USD rate is missing in JSON."])
                delegate?.didFailWithError(error: error)
                return nil
            }
            let currency = CurrencyModel(exchangeRate: rate)
            return currency
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
