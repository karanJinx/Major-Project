//
//  MedicationShowVC.swift
//  Project
//
//  Created by Humworld Solutions Private Limited on 22/09/23.
//

import Foundation
import UIKit

class MedicationShowVC: UIViewController{
    @IBOutlet var nameView: UIView!
    @IBOutlet var frequencyView: UIView!
    @IBOutlet var dateView: UIView!
    @IBOutlet var nameLable: UILabel!
    @IBOutlet var frequencyLable: UILabel!
    @IBOutlet var quantityLable: UILabel!
    @IBOutlet var effectiveDateLable: UILabel!
    @IBOutlet var lastEffectiveDateLable: UILabel!

    
    var medication1 = MedicationData()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        func customs(viewName:UIView){
            viewName.layer.cornerRadius = 10
            viewName.layer.shadowColor = UIColor.black.cgColor
            viewName.layer.shadowOpacity = 0.7
            viewName.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
            viewName.layer.shadowRadius = 5.0
        }
        customs(viewName: nameView)
        customs(viewName: frequencyView)
        customs(viewName: dateView)

        nameLable.text = medication1.name
        frequencyLable.text = medication1.frequency
        quantityLable.text = String(medication1.quantity!)
        effectiveDateLable.text = medication1.effectiveDate
        lastEffectiveDateLable.text = medication1.lastEffectiveDate
        
    }
}
