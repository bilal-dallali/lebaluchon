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
    @IBOutlet weak var weatherIcon: UIImageView!
    
    // New York layout
    @IBOutlet weak var newYorkWeatherTitle: UILabel!
    @IBOutlet weak var newYorkWeatherView: UIView!
    @IBOutlet weak var newYorkTemperatureLabel: UILabel!
    @IBOutlet weak var newYorkDescriptionLabel: UILabel!
    @IBOutlet var newYorkTownLabel: UILabel!
    @IBOutlet weak var newYorkWeatherIcon: UIImageView!
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Trigger a permission request
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        weatherManager.delegate = self
        searchTownTextField.delegate = self
        
        // FONTS
        weatherTitle.font = UIFont(name: "PlusJakartaSans-Bold", size: 28)
        newYorkWeatherTitle.font = UIFont(name: "PlusJakartaSans-Bold", size: 28)
        nowTemperatureLabel.font = UIFont(name: "PlusJakartaSans-Bold", size: 48)
        newYorkTemperatureLabel.font = UIFont(name: "PlusJakartaSans-Bold", size: 48)
        nowDescriptionLabel.font = UIFont(name: "PlusJakartaSans-SemiBold", size: 18)
        newYorkDescriptionLabel.font = UIFont(name: "PlusJakartaSans-SemiBold", size: 18)
        townLabel.font = UIFont(name: "PlusJakartaSans-Bold", size: 28)
        newYorkTownLabel.font = UIFont(name: "PlusJakartaSans-Bold", size: 28)
        nowDateLabel.font = UIFont(name: "PlusJakartaSans-Regular", size: 16)
        
        // TODAY WEATHER VIEW SHADOW COLOR
        nowWeatherView.layer.shadowColor = UIColor.black.cgColor
        nowWeatherView.layer.shadowOpacity = 0.25
        nowWeatherView.layer.shadowOffset = .init(width: 0, height: 4)
        nowWeatherView.layer.shadowRadius = 4
        
        // NEW YORK WEATHER VIEW SHADOW COLOR
        newYorkWeatherView.layer.shadowColor = UIColor.black.cgColor
        newYorkWeatherView.layer.shadowOpacity = 0.25
        newYorkWeatherView.layer.shadowOffset = .init(width: 0, height: 4)
        newYorkWeatherView.layer.shadowRadius = 4
        
        // Configure font and label color tabbar
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
            
            // Customise the icons color
            tabBar.unselectedItemTintColor = UIColor.init(red: 206/255, green: 249/255, blue: 242/255, alpha: 1)
            
            // Optional : customise icon color tabbar
            tabBar.tintColor = UIColor.init(red: 92/255, green: 112/255, blue: 171/255, alpha: 1)
        }
        
        weatherManager.fetchNyWeather()
    }
    
    func getLocalDateTimeString(for timezoneOffset: Int) -> String {
        let currentDate = Date()

        // Adding mannually summer time : four hours less
        let summerTimeAdjustment: TimeInterval = -1 * 3600
        let adjustedTime = currentDate.addingTimeInterval(TimeInterval(timezoneOffset) + summerTimeAdjustment)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, dd MMM yyyy   hh:mm a"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        return dateFormatter.string(from: adjustedTime)
    }
    
    @IBAction func locationButton(_ sender: UIButton) {
        locationManager.requestLocation()
    }
}

//MARK: - UITextFieldDelegate
extension WeatherViewController: UITextFieldDelegate {
    // SEARCH TOWN PRESSED
    @IBAction func searchTownPressed(_ sender: UIButton) {
        searchTownTextField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTownTextField.endEditing(true)
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
        if let town = searchTownTextField.text {
            weatherManager.fetchWeather(townName: town)
        }
        searchTownTextField.text = ""
    }
}

extension WeatherViewController: WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.nowTemperatureLabel.text = "\(weather.temperatureString)°C"
            self.weatherIcon.image = UIImage(systemName: weather.conditionName)
            self.nowDescriptionLabel.text = weather.description
            self.townLabel.text = weather.townName
            self.nowDateLabel.text = self.getLocalDateTimeString(for: weather.timezone)
        }
    }
    
    func didUpdateNyWeather(_ weatherManager: WeatherManager, weather: WeatherModelNy) {
        DispatchQueue.main.async {
            self.newYorkTemperatureLabel.text = "\(weather.temperatureString)°C"
            self.newYorkWeatherIcon.image = UIImage(systemName: weather.conditionName)
            self.newYorkDescriptionLabel.text = weather.description
            self.newYorkTownLabel.text = weather.townName
        }
    }
    
    func didFailWithError(error: any Error) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

//MARK: - CLLocationManagerDelegate
extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
