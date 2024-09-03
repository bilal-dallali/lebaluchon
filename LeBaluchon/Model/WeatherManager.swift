//
//  APICall.swift
//  LeBaluchon
//
//  Created by Bilal D on 04/07/2024.
//

import Foundation
import CoreLocation
//07bf46530bf88149822e9ff3fabf4bea

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=\(apiKey)&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(townName: String) {
        let urlString = "\(weatherURL)&q=\(townName)"
        performRequest(with: urlString)
        //print("Request URL: \(urlString)")
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        // CREATE A URL
        if let url = URL(string: urlString) {
            // CREATE A URLSESSION
            let session = URLSession(configuration: .default)
            // GIVE THE SESSION A TASK
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    //print(error!)
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJSON(weatherData: safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            // START THE TASK
            task.resume()
        }
    }
    
    func parseJSON(weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, townName: name, temperature: temp)
            return weather
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
