//
//  APICall.swift
//  LeBaluchon
//
//  Created by Bilal D on 04/07/2024.
//

import Foundation
//07bf46530bf88149822e9ff3fabf4bea

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=07bf46530bf88149822e9ff3fabf4bea&units=metric"
    
    func fetchWeather(townName: String) {
        let urlString = "\(weatherURL)&q\(townName)"
        performRequest(urlString: urlString)
        print(urlString)
    }
    
    func performRequest(urlString: String) {
        // CREATE A URL
        if let url = URL(string: urlString) {
            // CREATE A URLSESSION
            let session = URLSession(configuration: .default)
            // GIVE THE SESSION A TASK
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    print(error!)
                    return
                }
                
                if let safeData = data {
                    self.parseJSON(weatherData: safeData)
                }
            }
            // START THE TASK
            
            task.resume()
        }
    }
    
    func parseJSON(weatherData: Data) {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            print(decodedData.name)
        } catch {
            print(error)
        }
    }
}
