//
//  TabBarController.swift
//  LeBaluchon
//
//  Created by Bilal D on 27/06/2024.
//

import UIKit

class TabBarController: UITabBarController {
    
    @IBOutlet var tab: UITabBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tab.layer.shadowColor = UIColor.white.cgColor
        tab.layer.shadowOpacity = 0.1
        tab.layer.shadowOffset = .init(width: 0, height: -4)
        tab.layer.shadowRadius = 4
    }
}
