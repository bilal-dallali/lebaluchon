//
//  CurrencyViewController.swift
//  LeBaluchon
//
//  Created by Bilal D on 26/06/2024.
//

import UIKit

class CurrencyViewController: UIViewController {
    
    @IBOutlet var currencyTitle: UILabel!
    @IBOutlet var currencyMainView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // FONTS FOR THE APPLICATION
        currencyTitle.font = UIFont(name: "PlusJakartaSans-Bold", size: 28)
        
        
        // SHADOWS
        currencyMainView.layer.shadowColor = UIColor.white.cgColor
        currencyMainView.layer.shadowOpacity = 0.1
        currencyMainView.layer.shadowOffset = .init(width: -4, height: -4)
        currencyMainView.layer.shadowRadius = 4
        
        
    }
}
