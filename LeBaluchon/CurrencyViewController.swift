//
//  CurrencyViewController.swift
//  LeBaluchon
//
//  Created by Bilal D on 26/06/2024.
//

import UIKit

class CurrencyViewController: UIViewController {
    
    @IBOutlet weak var currencyTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if currencyTitle != nil {
            print("currencyTitle outlet is connected")
        } else {
            print("currencyTitle outlet is NOT connected")
        }
        
        currencyTitle.font = UIFont(name: "PlusJakartaSans-Bold", size: 28) ?? UIFont.systemFont(ofSize: 28, weight: .bold)
    }
}
