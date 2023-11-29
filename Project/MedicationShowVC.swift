//
//  MedicationShowVC.swift
//  Project
//
//  Created by Humworld Solutions Private Limited on 22/09/23.
//

import Foundation
import UIKit

class MedicationShowVC: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet var nameView: UIView!
    @IBOutlet var frequencyView: UIView!
    @IBOutlet var dateView: UIView!
    @IBOutlet var nameLable: UILabel!
    @IBOutlet var frequencyLable: UILabel!
    @IBOutlet var quantityLable: UILabel!
    @IBOutlet var effectiveDateLable: UILabel!
    @IBOutlet var lastEffectiveDateLable: UILabel!
    
    //MARK: - Properties
    var medicationToShow = MedicationData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavigationBar()
        
        customView(viewName: nameView)
        customView(viewName: frequencyView)
        customView(viewName: dateView)
        
        setPropertiesForLable(lable: nameLable)
        setPropertiesForLable(lable: frequencyLable)
        setPropertiesForLable(lable: quantityLable)
        setPropertiesForLable(lable: effectiveDateLable)
        setPropertiesForLable(lable: lastEffectiveDateLable)
        setPropertiesForLable(lable: nameLable)
        
    }
    //MARK: - SetValuesToLable
    func setPropertiesForLable(lable: UILabel) {
        lable.text = medicationToShow.name
        lable.text = medicationToShow.frequency
        lable.text = String(medicationToShow.quantity!)
        lable.text = medicationToShow.effectiveDate
        lable.text = medicationToShow.lastEffectiveDate ?? " - "
    }
    
    //MARK: - SetupNavigationBar
    func setUpNavigationBar(){
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = .systemGray6
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        // Set the status bar color to match the navigation bar
        navigationController?.navigationBar.barStyle = .black
        hidesBottomBarWhenPushed = true
    }
    
    //MARK: - customView
    /// setting corner radius and shadow for showing the medication in the list screen
    /// - Parameter viewName: parameter refering the UIView
    func customView(viewName:UIView){
        viewName.layer.cornerRadius = 5
        viewName.layer.shadowColor = UIColor.black.cgColor
        viewName.layer.shadowOpacity = 0.4
        viewName.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        viewName.layer.shadowRadius = 3.0
    }
}
