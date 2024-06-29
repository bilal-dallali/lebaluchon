//
//  TranslateViewController.swift
//  LeBaluchon
//
//  Created by Bilal D on 28/06/2024.
//

import UIKit

class TranslateViewController: UIViewController {
    
    @IBOutlet var translateTitle: UILabel!
    @IBOutlet var selectLanguageView: UIView!
    
    @IBOutlet var originLanguage: UILabel!
    @IBOutlet var resultLanguage: UILabel!
    @IBOutlet var translateFrom: UILabel!
    @IBOutlet var translateFromLanguage: UILabel!
    
    
    
    @IBAction func reverseButtonTranslate(_ sender: Any) {
        print("Reverse languages translate")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // FONTS
        translateTitle.font = UIFont(name: "PlusJakartaSans-Bold", size: 28)
        originLanguage.font = UIFont(name: "PlusJakartaSans-SemiBold", size: 16)
        resultLanguage.font = UIFont(name: "PlusJakartaSans-SemiBold", size: 16)
        translateFrom.font = UIFont(name: "PlusJakartaSans-SemiBold", size: 16)
        translateFromLanguage.font = UIFont(name: "PlusJakartaSans-SemiBold", size: 16)
        
        // SHADOWS
        selectLanguageView.layer.shadowColor = UIColor.black.cgColor
        selectLanguageView.layer.shadowOpacity = 0.25
        selectLanguageView.layer.shadowOffset = .init(width: 0, height: 4)
        selectLanguageView.layer.shadowRadius = 4
    }
}
