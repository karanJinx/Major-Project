//
//  WeightScalePopupVC.swift
//  Project
//
//  Created by Humworld Solutions Private Limited on 06/11/23.
//

import Foundation
import UIKit

class WeightScalePopupVC: UIViewController{
    
    //MARK: Properties
    var finalReading: String?
    
    //MARK: IBOutlets
    @IBOutlet var titleLable: UILabel!
    @IBOutlet var readingsLable: UILabel!
    @IBOutlet var popupview: UIView!
    @IBOutlet var buttonLable: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readingsLable.text = finalReading
        setUpView(view: popupview, radius: 7, maskToBound: true)
        setUpView(view: buttonLable, radius: 7, maskToBound: true)
        setUpView(view: titleLable, radius: 7, maskToBound: true)
    }
    
    //MARK: - setUpView
    func setUpView(view: UIView, radius: CGFloat, maskToBound: Bool){
        view.layer.cornerRadius = radius
        view.layer.masksToBounds = true
    }
    //MARK: IBActions
    @IBAction func buttonPressedNavigateToHome(_ sender: UIButton) {
        navigateToHomeScreen()
        print("Button working")
    }
    
    //MARK: - NavigationBackToHomeScreen
    func navigateToHomeScreen(){
        let myTabBar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabBar") as! UITabBarController
        //myTabBar.modalPresentationStyle = .overCurrentContext
        //self.present(myTabBar, animated: true)
        let scene = view.window?.windowScene?.delegate as? SceneDelegate
        let window = scene?.window
        window?.rootViewController = myTabBar
    }
    
}

