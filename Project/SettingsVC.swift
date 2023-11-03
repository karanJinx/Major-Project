//
//  SettingsVC.swift
//  Project
//
//  Created by Humworld Solutions Private Limited on 06/09/23.
//

import UIKit

class SettingVC:UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = .systemGray6 // Replace with the color you want
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance

        // Set the status bar color to match the navigation bar
        navigationController?.navigationBar.barStyle = .black
    }
    func performLogout(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(identifier: "LoginVC")
        let scene = view.window?.windowScene?.delegate as? SceneDelegate
        let window = scene?.window
        window?.rootViewController = vc
    }
    func showAlert(title:String,message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive,handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default,handler: { action in
            self.performLogout()
        }))
        self.present(alert, animated: true)
    }
    
    @IBAction func logOutButtontapped(_ sender: UIBarButtonItem){
        showAlert(title: "Alert!", message: "Are you sure want to logout")
        
        print("Logged out")
        
    }
    
}

