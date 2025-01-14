//
//  LanguageDetectionData.swift
//  LeBaluchon
//
//  Created by Bilal Dallali on 14/01/2025.
//

import Foundation

struct LanguageDetectionData: Codable {
    let data: DetectionData
}

struct DetectionData: Codable {
    let detections: [Detection]
}

struct Detection: Codable {
    let language: String
    let confidence: Double
}
