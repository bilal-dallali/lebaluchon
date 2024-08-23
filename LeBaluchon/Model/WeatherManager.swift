//
//  APICall.swift
//  LeBaluchon
//
//  Created by Bilal D on 04/07/2024.
//

import Foundation
//07bf46530bf88149822e9ff3fabf4bea

protocol WeatherManagerDelegate {
    func didUpdateWeather(weather: WeatherModel)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=07bf46530bf88149822e9ff3fabf4bea&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(townName: String) {
        let urlString = "\(weatherURL)&q=\(townName)"
        performRequest(urlString: urlString)
        //print("Request URL: \(urlString)")
    }
    
    func performRequest(urlString: String) {
        // CREATE A URL
        if let url = URL(string: urlString) {
            // CREATE A URLSESSION
            let session = URLSession(configuration: .default)
            // GIVE THE SESSION A TASK
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    //print(error!)
                    print("Error fetching data: \(error!.localizedDescription)")
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(weatherData: safeData) {
                        delegate?.didUpdateWeather(weather: weather)
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
            //print(weather.conditionName)
            //print(weather.temperatureString)
            //print(decodedData.weather[0].description)
            //print(decodedData.main.temp)
            //print(decodedData.weather[0].id)
        } catch {
            print(error)
            return nil
        }
    }
}
