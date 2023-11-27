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
    
    
    var medicationToShow = MedicationData()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = .systemGray6 
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
        // Set the status bar color to match the navigation bar
        navigationController?.navigationBar.barStyle = .black
        
        hidesBottomBarWhenPushed = true
        /// setting corner radius and shadow for showing the medication in the list screen
        /// - Parameter viewName: parameter refering the UIView
        func customs(viewName:UIView){
            viewName.layer.cornerRadius = 5
            viewName.layer.shadowColor = UIColor.black.cgColor
            viewName.layer.shadowOpacity = 0.4
            viewName.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
            viewName.layer.shadowRadius = 3.0
        }
        customs(viewName: nameView)
        customs(viewName: frequencyView)
        customs(viewName: dateView)
        
        nameLable.text = medicationToShow.name
        frequencyLable.text = medicationToShow.frequency
        quantityLable.text = String(medicationToShow.quantity!)
        effectiveDateLable.text = medicationToShow.effectiveDate
        lastEffectiveDateLable.text = medicationToShow.lastEffectiveDate ?? " - "
        
        
        
    }
}
