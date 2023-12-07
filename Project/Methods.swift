//
//  Methods.swift
//  Project
//
//  Created by Humworld Solutions Private Limited on 01/11/23.
//

import Foundation
import UIKit

struct Method {
    
    //MARK: - ShowingConfirmationAlertToGoback
    static func showConfirmationAlertToGoBackTo(from presentingViewController: UIViewController) {
        let alertController = UIAlertController(title: "Confirmation Alert", message: "Are you sure about navigating out of this screen?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { navigationController in
            if let navigationController = presentingViewController.navigationController {
                if let homeVC = navigationController.viewControllers.first(where: { $0 is HomeVC }) {
                    navigationController.popToViewController(homeVC, animated: true)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        // Add the actions to the alert controller
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        // Present the alert from the specified presenting view controller
        presentingViewController.present(alertController, animated: true, completion: nil)
    }
}
