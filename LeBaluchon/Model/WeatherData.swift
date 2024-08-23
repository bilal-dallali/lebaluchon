//
//  WeatherData.swift
//  LeBaluchon
//
//  Created by Bilal D on 06/08/2024.
//

import Foundation

struct WeatherData: Decodable {
    let name: String
    let main: Main
    let weather: [Weather]
}

struct Main: Decodable {
    let temp: Double
}

struct Weather: Decodable {
    let description: String
    let id: Int
}
