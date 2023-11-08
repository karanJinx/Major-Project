//
//  BloodPressurePopupVC.swift
//  Project
//
//  Created by Humworld Solutions Private Limited on 06/11/23.
//

import Foundation
import UIKit

class BloodPressurePopupVC: UIViewController{
    
    var systolicFinalreading: String?
    var diastolicFinalreading: String?
    var pulseFinalreading: String?
    @IBOutlet var popupView: UIView!
    @IBOutlet var titleLableBP: UILabel!
    @IBOutlet var systolicLable: UILabel!
    @IBOutlet var diastolicLable: UILabel!
    @IBOutlet var pulseLable: UILabel!
    @IBOutlet var OKButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let desiredCornerRadius: CGFloat = 5
        titleLableBP.layer.cornerRadius = desiredCornerRadius
        titleLableBP.layer.masksToBounds = true
        
        
        OKButton.layer.cornerRadius = 7
        popupView.layer.cornerRadius = 10
        
        systolicLable.text = systolicFinalreading
        diastolicLable.text = diastolicFinalreading
        pulseLable.text = pulseFinalreading
    }
    @IBAction func ButtonPressedToNavigateToHomescreen(_ sender: Any) {
        performSegue(withIdentifier: "PopToHomeVCFromBloodPressure", sender: self)
    }
    
}
