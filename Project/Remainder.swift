//
//  Remainder.swift
//  Project
//
//  Created by Humworld Solutions Private Limited on 30/09/23.
//

import Foundation
import UIKit
import UserNotifications

class LocalNotificationManager{
    static func requestPermission(){
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.sound,.alert,.badge]) { granted, error in
            if granted{
                print("The notification permission granter")
            }
            else{
                print("The notification permission denied")
            }
        }
    }
    
    
    //schedule notification
    static func scheduleMedicationRemainder(medicationName: String,frequency: String,quantity: String,date: String){
        let center = UNUserNotificationCenter.current()
        //Content of the notification
        let content = UNMutableNotificationContent()
        content.title = "Medication Remainder"
        content.body = "It's time to take \(medicationName) and take \(quantity) quantity"
        content.sound = UNNotificationSound.default
        //create a trigger - when to give notification
        var trigger: UNNotificationTrigger
        switch frequency{
        case "Every Alternative day":
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 48 * 60 * 60, repeats: true)
        case "Every 3 months":
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3 * 30 * 24 * 60 * 60, repeats: true)
        case "Every 8 hours":
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 8 * 60 * 60, repeats: true)//300   5 min
        case "Every 4 hours":
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 4 * 60 * 60, repeats: true)// 180  3 min
        case "Every 6 months":
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 6 * 30 * 24 * 60 * 60, repeats: true)
        case "Every 2 hours":
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2 * 60 * 60, repeats: true)// 120  2 min
        case "Once a week":
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 7 * 24 * 60 * 60, repeats: true)
        case "Once a month":
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30 * 24 * 60 * 60, repeats: true)
        case "Four times a day":
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 6 * 60 * 60, repeats: true)
        case "Three times a day":
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 8 * 60 * 60, repeats: true)
        case "Twice a day":
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 16 * 60 * 60, repeats: true)
        default:
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 24 * 60 * 60, repeats: false)
        }
        
        
        //Create a request
        //let medicationIdToRequest = medicationId
        
        let request = UNNotificationRequest(identifier: UUID().uuidString , content: content, trigger: trigger)
        
        //Register a request
        center.add(request) { error in
            if let error = error{
                print("Error in the Local Notification: \(error)")
            }
        }
        
    }
    
    
    //cancel the local notification
    static func removeLocalNotification(identifier: String){
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
