//
//  AfterReadingAlert.swift
//  Project
//
//  Created by Humworld Solutions Private Limited on 02/11/23.
//

import Foundation
import UIKit

struct AlertAfterReading{
    static func alertReadingHasTaken(title:String,message:String,viewController:UIViewController){
        let alertController = UIAlertController(title: title, message:message , preferredStyle: .alert)

        // Create an action for the alert
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)

        // Present the alert
            viewController.present(alertController, animated: true)
    }
}
