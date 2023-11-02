//
//  Methods.swift
//  Project
//
//  Created by Humworld Solutions Private Limited on 01/11/23.
//

import Foundation
import UIKit

    struct Method {
        static func showConfirmationAlertToGoBackTo(from presentingViewController: UIViewController, targetViewController: UIViewController) {
            let alertController = UIAlertController(title: "Confirmation", message: "Are you sure you want to go back.", preferredStyle: .alert)

            let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
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
