//
//  BloodGlucosePopupVC.swift
//  Project
//
//  Created by Humworld Solutions Private Limited on 07/11/23.
//

import Foundation
import UIKit

class BloodGlucosePopupVC:UIViewController{
    @IBOutlet var popupView: UIView!
    @IBOutlet var titleBGLable: UILabel!
    @IBOutlet var readingsLable: UILabel!
    @IBOutlet var button: UIButton!
    
    var finalReadings : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        readingsLable.text = finalReadings
        
        popupView.layer.cornerRadius = 5
        button.layer.cornerRadius = 5
        
        let desiredCornerRadius:CGFloat = 5
        titleBGLable.layer.cornerRadius = desiredCornerRadius
        titleBGLable.layer.masksToBounds = true
    }
    
    @IBAction func buttonPressedToNavigateToHomeVC(_ sender: Any) {
        performSegue(withIdentifier: "PopToHomeVCFromBloodGlucose", sender: self)
    }
}
