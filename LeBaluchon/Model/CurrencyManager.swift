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
    private let session: SessionProtocol
    var currencyURL = "https://data.fixer.io/api/latest?access_key=\(currencyApiKey)&base=EUR&symbols=USD"
    var delegate: CurrencyManagerDelegate?
    
    init(session: SessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    func fetchCurrency() {
        let urlString = currencyURL
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "InvalidURLError", code: 0, userInfo: [NSLocalizedDescriptionKey: "The URL provided is invalid."])
            delegate?.didFailWithError(error: error)
            return
        }
        
        session.perform(url: url) { (data, response, error) in
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
    }
    
    func parseJSON(currencyData: Data) -> CurrencyModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CurrencyData.self, from: currencyData)
            guard let rate = decodedData.rates["USD"] else {
                let error = NSError(domain: "MissingRateError", code: 0, userInfo: [NSLocalizedDescriptionKey: "USD rate is missing in JSON."])
                delegate?.didFailWithError(error: error)
                return nil
            }
            return CurrencyModel(exchangeRate: rate)
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}

protocol SessionProtocol {
//    func dataTask(
//        with url: URL,
//        completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void
//    ) -> URLSessionDataTask
    
    
    func perform(url: URL, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void)
        
    
}

extension URLSession: SessionProtocol {
    func perform(url: URL, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) {
        self.dataTask(with: url) { data, response, error in
        completionHandler(data, response, error)
                
        }.resume()
    }
}
