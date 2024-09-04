//
//  ViewController.swift
//  LeBaluchon
//
//  Created by Bilal D on 14/06/2024.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var weatherTitle: UILabel!
    
    @IBOutlet var searchTownTextField: UITextField!
    
    @IBOutlet weak var nowWeatherView: UIView!
    @IBOutlet weak var nowTemperatureLabel: UILabel!
    @IBOutlet weak var nowDescriptionLabel: UILabel!
    
    @IBOutlet var townLabel: UILabel!
    
    @IBOutlet weak var nowDateLabel: UILabel!
    @IBOutlet weak var nowHourLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var weekWeatherView: UIView!
    
    @IBOutlet weak var forecastStackView: UIStackView!
    
    @IBOutlet weak var hourlyForecastOutlet: UIButton!
    @IBOutlet weak var weeklyForecastOutlet: UIButton!
    
    @IBOutlet weak var weatherPrevision1: UIStackView!
    @IBOutlet weak var weatherPrevision2: UIStackView!
    @IBOutlet weak var weatherPrevision3: UIStackView!
    @IBOutlet weak var weatherPrevision4: UIStackView!
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // DATE AND HOUR
        //nowDateLabel.text = getCustomDateString()
        //nowHourLabel.text = getCurrentTimeString()
        
        // Trigger a permission request
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        weatherManager.delegate = self
        searchTownTextField.delegate = self
        
        // FONTS
        weatherTitle.font = UIFont(name: "PlusJakartaSans-Bold", size: 28)
        nowTemperatureLabel.font = UIFont(name: "PlusJakartaSans-Bold", size: 64)
        nowDescriptionLabel.font = UIFont(name: "PlusJakartaSans-SemiBold", size: 18)
        townLabel.font = UIFont(name: "PlusJakartaSans-Bold", size: 28)
        nowDateLabel.font = UIFont(name: "PlusJakartaSans-Regular", size: 16)
        nowHourLabel.font = UIFont(name: "PlusJakartaSans-Regular", size: 16)
        
        // TODAY WEATHER VIEW SHADOW COLOR
        nowWeatherView.layer.shadowColor = UIColor.black.cgColor
        nowWeatherView.layer.shadowOpacity = 0.25
        nowWeatherView.layer.shadowOffset = .init(width: 0, height: 4)
        nowWeatherView.layer.shadowRadius = 4
        
        // WEEK WEATHER VIEW SHADOW COLOR
        weekWeatherView.layer.shadowColor = UIColor.black.cgColor
        weekWeatherView.layer.shadowOpacity = 0.25
        weekWeatherView.layer.shadowOffset = .init(width: 0, height: 4)
        weekWeatherView.layer.shadowRadius = 4
        
        // FORESTACKVIEW SHADOWCOLOR
        forecastStackView.layer.shadowColor = UIColor.black.cgColor
        forecastStackView.layer.shadowOpacity = 0.25
        forecastStackView.layer.shadowOffset = .init(width: 0, height: 4)
        forecastStackView.layer.shadowRadius = 4
        
        weatherPrevision1.layer.shadowColor = UIColor.black.cgColor
        weatherPrevision1.layer.shadowOpacity = 0.25
        weatherPrevision1.layer.shadowOffset = .init(width: 0, height: 4)
        weatherPrevision1.layer.shadowRadius = 4
        
        weatherPrevision2.layer.shadowColor = UIColor.black.cgColor
        weatherPrevision2.layer.shadowOpacity = 0.25
        weatherPrevision2.layer.shadowOffset = .init(width: 0, height: 4)
        weatherPrevision2.layer.shadowRadius = 4
        
        weatherPrevision3.layer.shadowColor = UIColor.black.cgColor
        weatherPrevision3.layer.shadowOpacity = 0.25
        weatherPrevision3.layer.shadowOffset = .init(width: 0, height: 4)
        weatherPrevision3.layer.shadowRadius = 4
        
        weatherPrevision4.layer.shadowColor = UIColor.black.cgColor
        weatherPrevision4.layer.shadowOpacity = 0.25
        weatherPrevision4.layer.shadowOffset = .init(width: 0, height: 4)
        weatherPrevision4.layer.shadowRadius = 4
        
        // SET THE COLOR FOR WEEKLY FORECAST
        weeklyForecastOutlet.backgroundColor = UIColor(red: 28/255, green: 33/255, blue: 47/255, alpha: 1)
        
        // Configuration de la police et de la couleur des labels de la tab bar
        if let tabBar = self.tabBarController?.tabBar {
            let tabBarAppearance = UITabBarItem.appearance()
            let attributesNormal = [
                NSAttributedString.Key.font: UIFont(name: "PlusJakartaSans-SemiBold", size: 12)!,
                NSAttributedString.Key.foregroundColor: UIColor.init(red: 206/255, green: 249/255, blue: 242/255, alpha: 1)
            ]
            let attributesSelected = [
                NSAttributedString.Key.font: UIFont(name: "PlusJakartaSans-Bold", size: 14)!,
                NSAttributedString.Key.foregroundColor: UIColor.init(red: 92/255, green: 112/255, blue: 171/255, alpha: 1)
            ]
            
            tabBarAppearance.setTitleTextAttributes(attributesNormal, for: .normal)
            tabBarAppearance.setTitleTextAttributes(attributesSelected, for: .selected)
            
            // Optionnel : customiser la couleur de fond de la tab bar
            // tabBar.barTintColor = UIColor.purple
            
            // Customiser la couleur des icônes de la tab bar lorsqu'elles ne sont pas sélectionnées
            tabBar.unselectedItemTintColor = UIColor.init(red: 206/255, green: 249/255, blue: 242/255, alpha: 1)
            
            // Optionnel : customiser la couleur des icônes de la tab bar
            tabBar.tintColor = UIColor.init(red: 92/255, green: 112/255, blue: 171/255, alpha: 1)
        }
    }
    
//    func getCustomDateString() -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "E, dd MMMM" // Format personnalisé pour la date seulement
//        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Pour garantir le formatage en anglais
//        let currentDate = Date()
//        return dateFormatter.string(from: currentDate)
//    }
//    
//    func getCurrentTimeString() -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "hh:mm a" // Format en 12 heures avec AM/PM
//        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Pour garantir le formatage correct
//        let currentTime = Date()
//        return dateFormatter.string(from: currentTime)
//    }
    
    func getLocalDateTimeString(for timezoneOffset: Int) -> String {
        let currentDate = Date()
        let localTime = currentDate.addingTimeInterval(TimeInterval(timezoneOffset))  // Ajoute le décalage du fuseau horaire
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, dd MMM yyyy hh:mm a"  // Format pour la date et l'heure
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.string(from: localTime)
    }
    
//    func getLocalTimeString(for timezoneOffset: Int) -> String {
//        let currentDate = Date()
//        let localTime = currentDate.addingTimeInterval(TimeInterval(timezoneOffset))  // Ajoute le décalage du fuseau horaire
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "hh:mm a"  // Format pour l'heure uniquement
//        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
//        return dateFormatter.string(from: localTime)
//    }
    
    // YOU CLICK ON HOURLY FORECAST TO DISPLAY THE WEATHER OF THE DAY
    @IBAction func hourlyForecast(_ sender: UIButton) {
        print("Hour")
        weeklyForecastOutlet.backgroundColor = UIColor(red: 28/255, green: 33/255, blue: 47/255, alpha: 1)
        hourlyForecastOutlet.backgroundColor = UIColor(red: 92/255, green: 112/255, blue: 171/255, alpha: 1)
    }
    
    // YOU CLICK ON WEEKLY FORECAST TO DISPLAY THE WEATHER OF THE WEEK
    @IBAction func weeklyForecast(_ sender: Any) {
        print("week")
        hourlyForecastOutlet.backgroundColor = UIColor(red: 28/255, green: 33/255, blue: 47/255, alpha: 1)
        weeklyForecastOutlet.backgroundColor = UIColor(red: 92/255, green: 112/255, blue: 171/255, alpha: 1)
    }
    
    @IBAction func locationButton(_ sender: UIButton) {
        //nowDateLabel.text = getCustomDateString()
        //nowHourLabel.text = getCurrentTimeString()
        locationManager.requestLocation()
    }
}

//MARK: - UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate {
    // SEARCH TOWN PRESSED
    @IBAction func searchTownPressed(_ sender: UIButton) {
        //nowDateLabel.text = getCustomDateString()
        searchTownTextField.endEditing(true)
        print(searchTownTextField.text!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTownTextField.endEditing(true)
        print(searchTownTextField.text!)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if searchTownTextField.text != "" {
            return true
        } else {
            searchTownTextField.placeholder = "Better if you type something"
            return false
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        // USE SEARCHFIELD.TEXT TO GET THE WEATHER FOR THIS CITY
        //print(searchTownTextField.text!)
        if let town = searchTownTextField.text {
            weatherManager.fetchWeather(townName: town)
        }
        searchTownTextField.text = ""
    }
}

extension WeatherViewController: WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        print("It is", weather.temperature)
        DispatchQueue.main.async {
            self.nowTemperatureLabel.text = "\(weather.temperatureString)°C"
            //weather.temperatureString
            self.weatherIcon.image = UIImage(systemName: weather.conditionName)
            self.nowDescriptionLabel.text = weather.description
            self.townLabel.text = weather.townName
            self.nowDateLabel.text = self.getLocalDateTimeString(for: weather.timezone)
        }
    }
    
    func didFailWithError(error: any Error) {
        print(error)
    }
}

//MARK: - CLLocationManagerDelegate
extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            //print(lat)
            //print(lon)
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
