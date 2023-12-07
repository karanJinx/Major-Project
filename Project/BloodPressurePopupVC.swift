//
//  BloodPressurePopupVC.swift
//  Project
//
//  Created by Humworld Solutions Private Limited on 06/11/23.
//

import Foundation
import UIKit

class BloodPressurePopupVC: UIViewController{
    
    //MARK: Properties
    var systolicFinalreading: String?
    var diastolicFinalreading: String?
    var pulseFinalreading: String?
    
    //MARK: - IBOutlets
    @IBOutlet var popupView: UIView!
    @IBOutlet var titleLableBP: UILabel!
    @IBOutlet var systolicLable: UILabel!
    @IBOutlet var diastolicLable: UILabel!
    @IBOutlet var pulseLable: UILabel!
    @IBOutlet var OKButton: UIButton!
    
    //MARK: OverrideViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
    }
    
    //MARK: - InitialSetup
    func initialSetUp() {
        systolicLable.text = systolicFinalreading
        diastolicLable.text = diastolicFinalreading
        pulseLable.text = pulseFinalreading

        setUpView(view: titleLableBP, radius: 7, maskToBound: true)
        setUpView(view: OKButton, radius: 7, maskToBound: true)
        setUpView(view: popupView, radius: 7, maskToBound: true)
    }
    
    //MARK: - setUpView
    func setUpView(view: UIView, radius: CGFloat, maskToBound: Bool){
        view.layer.cornerRadius = radius
        view.layer.masksToBounds = maskToBound
    }
    
    //MARK: - IBAction
    @IBAction func ButtonPressedToNavigateToHomescreen(_ sender: Any) {
       navigateToHome()
    }
    
    //MARK: - NavigationBackToHomeScreen
    func navigateToHome(){
        let tabbar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabBar") as! UITabBarController
        //tabbar.modalPresentationStyle = .overCurrentContext
        //present(tabbar, animated: true)
        let scene = view.window?.windowScene?.delegate as? SceneDelegate
        let window = scene?.window
        window?.rootViewController = tabbar
    }
}
