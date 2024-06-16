//
//  ViewController.swift
//  LeBaluchon
//
//  Created by Bilal D on 14/06/2024.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var weatherTitle: UILabel!
    @IBOutlet weak var nowWeatherView: UIView!
    @IBOutlet weak var nowTemperature: UILabel!
    @IBOutlet weak var nowDescriptionWeather: UILabel!
    @IBOutlet weak var town: UILabel!
    @IBOutlet weak var todayDate: UILabel!
    @IBOutlet weak var nowHour: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var weekWeatherView: UIView!
    
    @IBOutlet weak var forecastStackView: UIStackView!
    
    @IBOutlet weak var hourlyForecastOutlet: UIButton!
    @IBOutlet weak var weeklyForecastOutlet: UIButton!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // FONTS
        weatherTitle.font = UIFont(name: "PlusJakartaSans-Bold", size: 28)
        nowTemperature.font = UIFont(name: "PlusJakartaSans-Bold", size: 64)
        nowDescriptionWeather.font = UIFont(name: "PlusJakartaSans-SemiBold", size: 18)
        town.font = UIFont(name: "PlusJakartaSans-Bold", size: 28)
        todayDate.font = UIFont(name: "PlusJakartaSans-Regular", size: 16)
        nowHour.font = UIFont(name: "PlusJakartaSans-Regular", size: 16)
        
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
        
        // SET THE COLOR FOR WEEKLY FORECAST
        weeklyForecastOutlet.backgroundColor = UIColor(red: 28/255, green: 33/255, blue: 47/255, alpha: 1)
    }


}

