//
//  WeatherModel.swift
//  LeBaluchon
//
//  Created by Bilal D on 14/08/2024.
//

import Foundation

struct WeatherModel {
    let conditionId: Int
    let townName: String
    let temperature: Double
    
    var temperatureString: String {
        return String(format: "%.0f", temperature)
    }
    
    var conditionName: String {
        switch conditionId {
        case 200...232:
            return "cloud.bolt.fill"
        case 300...321:
            return "cloud.drizzle.fill"
        case 500...531:
            return "cloud.rain.fill"
        case 600...622:
            return "cloud.snow.fill"
        case 701...781:
            return "cloud.fog.fill"
        case 800:
            return "sun.max.fill"
        case 801...804:
            return "cloud.sun.fill"
        default:
            return "cloud.sun.fill"
        }
    }
    
    var description: String {
        switch conditionId {
        case 200...232:
            return "Thunderstorm"
        case 300...321:
            return "Light rain"
        case 500...531:
            return "Heavy rain"
        case 600...622:
            return "Snowfall"
        case 701...781:
            return "Foggy"
        case 800:
            return "Clear sky"
        case 801...804:
            return "Partly cloudy"
        default:
            return "Partly cloudy"
        }
    }
}
