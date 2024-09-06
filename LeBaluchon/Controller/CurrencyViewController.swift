//
//  CurrencyViewController.swift
//  LeBaluchon
//
//  Created by Bilal D on 26/06/2024.
//

import UIKit

class CurrencyViewController: UIViewController, CurrencyManagerDelegate {
    
    @IBOutlet var currencyTitle: UILabel!
    @IBOutlet var currencyMainView: UIView!
    
    @IBOutlet var originCurrency: UILabel!
    @IBOutlet var resultCurrency: UILabel!
    
    @IBOutlet var originTextfield: UITextField!
    @IBOutlet var resultTextfield: UITextField!
    
    var currencyManager = CurrencyManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currencyManager.delegate = self
        
        // FONTS FOR THE APPLICATION
        currencyTitle.font = UIFont(name: "PlusJakartaSans-Bold", size: 28)
        originCurrency.font = UIFont(name: "PlusJakartaSans-Bold", size: 18)
        resultCurrency.font = UIFont(name: "PlusJakartaSans-Bold", size: 18)
        
        // SHADOWS
        currencyMainView.layer.shadowColor = UIColor.white.cgColor
        currencyMainView.layer.shadowOpacity = 0.1
        currencyMainView.layer.shadowOffset = .init(width: -4, height: -4)
        currencyMainView.layer.shadowRadius = 4
        
    }
    
    @IBAction func reverseButton(_ sender: Any) {
        print("reverse")
    }
    
    @IBAction func convertButton(_ sender: Any) {
        print("Convert")
        if let amountString = originTextfield.text, let amount = Double(amountString) {
            currencyManager.fetchCurrency()
        }
    }
    
    func didUpdateCurrency(_ currencyManager: CurrencyManager, currency: CurrencyModel) {
        DispatchQueue.main.async {
            if let amountString = self.originTextfield.text, let amount = Double(amountString) {
                let convertedAmount = amount * currency.exchangeRate
                self.resultTextfield.text = String(format: "%.2f", convertedAmount)
            }
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}
