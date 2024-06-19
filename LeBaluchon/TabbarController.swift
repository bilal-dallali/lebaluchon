//
//  TabbarController.swift
//  LeBaluchon
//
//  Created by Bilal D on 19/06/2024.
//


import UIKit

class TabbarController: UITabBarController, UITabBarControllerDelegate {
    
    @IBOutlet var tabbar: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabbar.layer.shadowColor = UIColor.white.cgColor
        tabbar.layer.shadowOpacity = 0.1
        tabbar.layer.shadowOffset = .init(width: 0, height: -4)
        tabbar.layer.shadowRadius = 4
    }
}

