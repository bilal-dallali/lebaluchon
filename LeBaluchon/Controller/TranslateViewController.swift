//
//  TranslateViewController.swift
//  LeBaluchon
//
//  Created by Bilal D on 28/06/2024.
//

import UIKit

class TranslateViewController: UIViewController, TranslateManagerDelegate {
    
    @IBOutlet var translateTitle: UILabel!
    @IBOutlet var selectLanguageView: UIView!
    
    @IBOutlet var originLanguage: UILabel!
    @IBOutlet var resultLanguage: UILabel!
    @IBOutlet var translateFrom: UILabel!
    @IBOutlet var translateFromLanguage: UILabel!
    
    @IBOutlet var translateTo: UILabel!
    @IBOutlet var translateToLanguage: UILabel!
    
    @IBOutlet var inputLanguageTextview: UITextView!
    @IBOutlet var resultTextview: UITextView!
    
    @IBOutlet var translateButtonOutlet: UIButton!
    
    var translateManager = TranslateManager()
    
    @IBAction func reverseButtonTranslate(_ sender: Any) {
        print("Reverse languages translate")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        translateManager.delegate = self
        
        // FONTS
        translateTitle.font = UIFont(name: "PlusJakartaSans-Bold", size: 28)
        originLanguage.font = UIFont(name: "PlusJakartaSans-SemiBold", size: 16)
        resultLanguage.font = UIFont(name: "PlusJakartaSans-SemiBold", size: 16)
        translateFrom.font = UIFont(name: "PlusJakartaSans-SemiBold", size: 16)
        translateFromLanguage.font = UIFont(name: "PlusJakartaSans-SemiBold", size: 16)
        translateTo.font = UIFont(name: "PlusJakartaSans-SemiBold", size: 16)
        translateToLanguage.font = UIFont(name: "PlusJakartaSans-SemiBold", size: 16)
        inputLanguageTextview.font = UIFont(name: "PlusJakartaSans-SemiBold", size: 16)
        
        // SHADOWS
        selectLanguageView.layer.shadowColor = UIColor.black.cgColor
        selectLanguageView.layer.shadowOpacity = 0.25
        selectLanguageView.layer.shadowOffset = .init(width: 0, height: 4)
        selectLanguageView.layer.shadowRadius = 4
        
//        inputLanguageTextview.layer.shadowColor = UIColor.systemGreen.cgColor
//        inputLanguageTextview.layer.shadowOpacity = 0.25
//        inputLanguageTextview.layer.shadowOffset = CGSize(width: 20, height: 20)
//        inputLanguageTextview.layer.shadowRadius = 40
    }
    
    @IBAction func translateButton(_ sender: Any) {
        print("Translate")
        if let textToTranslate = inputLanguageTextview.text {
            translateManager.fetchTranslation(text: textToTranslate, sourceLang: "fr", targetLang: "en")
        }
    }
    
    func didUpdateTranslation(_ translateManager: TranslateManager, translation: TranslateModel) {
        DispatchQueue.main.async {
            self.resultTextview.text = translation.translatedText
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}
