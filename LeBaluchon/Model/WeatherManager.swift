//
//  APICall.swift
//  LeBaluchon
//
//  Created by Bilal D on 04/07/2024.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didUpdateNyWeather(_ weatherManager: WeatherManager, weather: WeatherModelNy)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=\(weatherApiKey)&units=metric"
    
    var delegate: WeatherManagerDelegate?
    var session: SessionProtocol = URLSession.shared
    
    func fetchWeather(townName: String) {
        let urlString = "\(weatherURL)&q=\(townName)"
        performRequest(with: urlString)
    }
    
    func fetchNyWeather() {
        let urlString = "\(weatherURL)&q=New York"
        performNyRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        guard let url = URL(string: urlString), url.scheme != nil, url.host != nil else {
            let error = NSError(domain: "InvalidURLError", code: 0, userInfo: [NSLocalizedDescriptionKey: "The URL provided is invalid."])
            delegate?.didFailWithError(error: error)
            return
        }
        
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                self.delegate?.didFailWithError(error: error)
                return
            }
            
            guard let safeData = data else {
                let error = NSError(domain: "NoDataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data returned from server."])
                self.delegate?.didFailWithError(error: error)
                return
            }
            
            if let weather = self.parseJSON(weatherData: safeData) {
                self.delegate?.didUpdateWeather(self, weather: weather)
            } else {
                let error = NSError(domain: "ParseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse JSON."])
                self.delegate?.didFailWithError(error: error)
            }
        }
        
        task.resume()
    }
    
    func performNyRequest(with urlString: String) {
        // CREATE A URL
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "InvalidURLError", code: 0, userInfo: [NSLocalizedDescriptionKey: "The URL provided is invalid."])
            self.delegate?.didFailWithError(error: error)
            return
        }
        
        // CREATE A URLSESSION
        let session = URLSession(configuration: .default)
        // GIVE THE SESSION A TASK
        let task = session.dataTask(with: url) { (data, response, error) in
//            if error != nil {
//                self.delegate?.didFailWithError(error: error!)
//                return
//            }
            if let safeData = data {
                if let weather = self.parseNyJSON(weatherData: safeData) {
                    self.delegate?.didUpdateNyWeather(self, weather: weather)
                }
            }
        }
        // START THE TASK
        task.resume()
    }
    
    func parseJSON(weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            let timezone = decodedData.timezone
            
            let weather = WeatherModel(conditionId: id, townName: name, temperature: temp, timezone: timezone)
            return weather
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    func parseNyJSON(weatherData: Data) -> WeatherModelNy? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            let timezone = decodedData.timezone
            
            let weather = WeatherModelNy(conditionId: id, townName: name, temperature: temp, timezone: timezone)
            return weather
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
