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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        weatherTitle.font = UIFont(name: "PlusJakartaSans-Bold", size: 28)
        //weatherTitle.font = UIFont(name: "PlaywriteNL-Regular", size: 28)
        nowTemperature.font = UIFont(name: "PlusJakartaSans-Bold", size: 64)
        nowDescriptionWeather.font = UIFont(name: "PlusJakartaSans-SemiBold", size: 18)
        town.font = UIFont(name: "PlusJakartaSans-Bold", size: 28)
        todayDate.font = UIFont(name: "PLusJakartaSans-Regular", size: 16)
        nowHour.font = UIFont(name: "PLusJakartaSans-Regular", size: 16)
        
        nowWeatherView.layer.shadowColor = UIColor.white.cgColor
        nowWeatherView.layer.shadowOpacity = 0.1
        nowWeatherView.layer.shadowOffset = .init(width: -4, height: -4)
        nowWeatherView.layer.shadowRadius = 4
    }


}

