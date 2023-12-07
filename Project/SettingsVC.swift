//
//  SettingsVC.swift
//  Project
//
//  Created by Humworld Solutions Private Limited on 06/09/23.
//

import UIKit

class SettingVC: UIViewController {
    
    //MARK: - IBOutlet
    @IBOutlet var logoutView: UIView!
    @IBOutlet var patienIdLable: UILabel!
    @IBOutlet var carePlanIdLable: UILabel!
    
    //MARK: - OverrideViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        
        patienIdLable.text = Details.patientId
        if let carePlanId = Details.careplanId {
            carePlanIdLable.text = String(carePlanId)
        }
        logoutView.layer.cornerRadius = 10
    }
    
    //MARK: - SetupNavigationBar
    func setUpNavigationBar() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = .systemGray6
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        // Set the status bar color to match the navigation bar
        navigationController?.navigationBar.barStyle = .black
    }
    
    //MARK: - PerformLogout
    func performLogout() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(identifier: "LoginVC")
        let scene = view.window?.windowScene?.delegate as? SceneDelegate
        let window = scene?.window
        window?.rootViewController = vc
        print("Logged out")
    }
    
    //MARK: - ShowAlertBeforeLogout
    func showAlert(title:String,message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive,handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default,handler: { action in
            self.performLogout()
        }))
        self.present(alert, animated: true)
    }
    
    //MARK: - IBAction
    @IBAction func logOutButtontapped(_ sender: UIButton) {
        showAlert(title: "Alert!", message: "Are you sure want to logout")
    }
}

