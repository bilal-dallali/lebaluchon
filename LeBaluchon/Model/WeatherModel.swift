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
    let timezone: Int
    
    var temperatureString: String {
        return String(format: "%.0f", temperature.rounded(.awayFromZero))
    }
    
    var conditionName: String {
        switch conditionId {
            case 200...232:
                return "cloud.bolt.fill" // Orage
            case 300...321:
                return "cloud.drizzle.fill" // Bruine
            case 500...531:
                return "cloud.rain.fill" // Pluie
            case 600...622:
                return "cloud.snow.fill" // Neige
            case 701...781:
                return "smoke.fill" // Brouillard ou conditions spéciales
            case 800:
                return "sun.max.fill" // Ciel clair
            case 801:
                return "cloud.fill" // Quelques nuages
            case 802...804:
                return "cloud.sun.fill" // Nuages partiellement ensoleillés
            default:
                return "questionmark.circle" // Par défaut
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

struct WeatherModelNy {
    let conditionId: Int
    let townName: String
    let temperature: Double
    let timezone: Int
    
    var temperatureString: String {
        return String(format: "%.0f", temperature.rounded(.awayFromZero))
    }
    
    var conditionName: String {
        switch conditionId {
            case 200...232:
                return "cloud.bolt.fill" // Orage
            case 300...321:
                return "cloud.drizzle.fill" // Bruine
            case 500...531:
                return "cloud.rain.fill" // Pluie
            case 600...622:
                return "cloud.snow.fill" // Neige
            case 701...781:
                return "smoke.fill" // Brouillard ou conditions spéciales
            case 800:
                return "sun.max.fill" // Ciel clair
            case 801:
                return "cloud.fill" // Quelques nuages
            case 802...804:
                return "cloud.sun.fill" // Nuages partiellement ensoleillés
            default:
                return "questionmark.circle" // Par défaut
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
