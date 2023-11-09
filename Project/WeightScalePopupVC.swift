//
//  WeightScalePopupVC.swift
//  Project
//
//  Created by Humworld Solutions Private Limited on 06/11/23.
//

import Foundation
import UIKit

class WeightScalePopupVC: UIViewController{
    
    var finalReading: String?
    @IBOutlet var titleLable: UILabel!
    @IBOutlet var readingsLable: UILabel!
    @IBOutlet var popupview: UIView!
    @IBOutlet var buttonLable: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        readingsLable.text = finalReading
        popupview.layer.cornerRadius = 15
        buttonLable.layer.cornerRadius = 7
        
        let desiredCornerRadius: CGFloat = 5
        titleLable.layer.cornerRadius = desiredCornerRadius
        titleLable.layer.masksToBounds = true
     
    
    }
    @IBAction func buttonPressedNavigateToHome(_ sender: UIButton) {
        navigateToHomeScreen()
        print("Button working")
    }
    
    func navigateToHomeScreen(){
        let myTabBar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabBar") as! UITabBarController
        myTabBar.modalPresentationStyle = .overCurrentContext
        self.present(myTabBar, animated: true)
        
    }
    
}

