//
//  CurrencyViewController.swift
//  LeBaluchon
//
//  Created by Bilal D on 26/06/2024.
//

import UIKit

class CurrencyViewController: UIViewController {
    
    @IBOutlet var currencyTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currencyTitle.font = UIFont(name: "PlusJakartaSans-Bold", size: 28)
    }
}
