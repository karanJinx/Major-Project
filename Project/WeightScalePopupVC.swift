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
        performSegue(withIdentifier: "PopToHomeVCFromWeightScale", sender: self)
        print("Button working")
    }
    
//    func navigateToHomeScreen(from presentingViewController: UIViewController, targetViewController: UIViewController){
//        if let homeVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeVC") as? HomeVC {
//            if let navcontroller = self.navigationController{
//                navcontroller.popToViewController(homeVc, animated: false)
//                navcontroller.pushViewController(homeVc, animated: true)
//            }
//        }
        //dismiss(animated: true,completion: nil)
        
//    }
    
}

