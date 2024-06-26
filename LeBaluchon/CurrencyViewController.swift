//
//  CurrencyViewController.swift
//  LeBaluchon
//
//  Created by Bilal D on 26/06/2024.
//

import UIKit

class CurrencyViewController: UIViewController {
    
    //@IBOutlet weak var currencyTitle: UILabel!
    
    @IBOutlet var currencyTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currencyTitle.font = UIFont(name: "PlusJakartaSans-Bold", size: 28)
    }
}
