//
//  BloodGlucosePopupVC.swift
//  Project
//
//  Created by Humworld Solutions Private Limited on 07/11/23.
//

import Foundation
import UIKit

class BloodGlucosePopupVC:UIViewController{
    
    //MARK: - Properties
    var finalReadings: String?

    //MARK: - IBOutlets
    @IBOutlet var popupView: UIView!
    @IBOutlet var titleBGLable: UILabel!
    @IBOutlet var readingsLable: UILabel!
    @IBOutlet var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        readingsLable.text = finalReadings
        
//        popupView.layer.cornerRadius = 7
//        button.layer.cornerRadius = 7
//        titleBGLable.layer.cornerRadius = 7
//        titleBGLable.layer.masksToBounds = true
        setUpView(view: popupView, radius: 7, maskToBound: true)
        setUpView(view: button, radius: 7, maskToBound: true)
        setUpView(view: titleBGLable, radius: 7, maskToBound: true)
    }
    //MARK: - SetUpView
    func setUpView(view: UIView, radius: CGFloat, maskToBound: Bool) {
        view.layer.cornerRadius = radius
        view.layer.masksToBounds = maskToBound
    }
    
    //MARK: - IBAction
    @IBAction func buttonPressedToNavigateToHomeVC(_ sender: Any) {
        navigateToHome()
    }
    
    //MARK: - NavigationBackToHomeScreen
    func navigateToHome() {
        let tabbar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabBar") as! UITabBarController
        tabbar.modalPresentationStyle = .overCurrentContext
        //present(tabbar, animated: true)
        let scene = view.window?.windowScene?.delegate as? SceneDelegate
        let window = scene?.window
        window?.rootViewController = tabbar
    }
}
