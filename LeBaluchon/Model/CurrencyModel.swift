//
//  CurrencyModel.swift
//  LeBaluchon
//
//  Created by Bilal D on 05/09/2024.
//

import Foundation

struct CurrencyModel {
    let exchangeRate: Double
    
    var exchangeRateString: String {
        return String(format: "%.2f", exchangeRate)
    }
}
