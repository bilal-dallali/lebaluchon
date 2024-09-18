//
//  TranslateData.swift
//  LeBaluchon
//
//  Created by Bilal D on 12/09/2024.
//

import Foundation

struct TranslateData: Codable {
    let data: TranslationData
}

struct TranslationData: Codable {
    let translations: [Translation]
}

struct Translation: Codable {
    let translatedText: String
}
