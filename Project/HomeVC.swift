//
//  HomeVC.swift
//  Project
//
//  Created by Humworld Solutions Private Limited on 06/09/23.
//

import Foundation
import UIKit

class HomeVC: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet var weightscaleView: UIView!
    @IBOutlet var BloodPressureView: UIView!
    @IBOutlet var bloodGlucoseView: UIView!
    @IBOutlet var ecgView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurationToView(viewname: weightscaleView)
        configurationToView(viewname: bloodGlucoseView)
        configurationToView(viewname: BloodPressureView)
        configurationToView(viewname: ecgView)
        setUpNavigationBar()
        
    }
    //MARK: - SetUpNavigation
    func setUpNavigationBar() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = .systemGray6
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        // Set the status bar color to match the navigation bar
        navigationController?.navigationBar.barStyle = .default
    }
    
    //MARK: - ConfigurationToView
    /// setting the cornerRadius and the shadow  for the buttons
    /// - Parameter viewname: It is the view
    func configurationToView(viewname:UIView) {
        viewname.layer.cornerRadius = 20
        viewname.layer.shadowColor = UIColor.black.cgColor
        viewname.layer.shadowOpacity = 0.7
        viewname.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        viewname.layer.shadowRadius = 7.0
    }
    
    //MARK: - NavigationToOtherScreen
    /// this method refers to navigate to the respective device screens
    /// - Parameter identifier: it is the identifier we are setting in the storyboard(Identity inspector)
    func navigation(identifier: String) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(identifier: identifier)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //MARK: - IBActions
    @IBAction func weighingScaleButton(_ sender: Any) {
        navigation(identifier: "WeighingScaleVC")
    }
    @IBAction func EcgButtonTapped(_ sender: Any) {
        navigation(identifier: "EcgVC")
    }
    @IBAction func bloodPressureButtonTapped(_ sender: Any) {
        navigation(identifier: "BloodPressureVC")
    }
    @IBAction func bloodGlucoseButtonTapped(_ sender: Any) {
        navigation(identifier: "BloodGlucoseVC")
    }
}
