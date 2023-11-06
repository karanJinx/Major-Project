//
//  WeighingScaleVC.swift
//  Project
//
//  Created by Humworld Solutions Private Limited on 07/09/23.
//

import Foundation
import UIKit
import CoreBluetooth

enum WeightBLEReadingoptions: String {
    case unstableReading = "A0"
    case finalReading = "AA"
}

class WeighingScaleVC: UIViewController{
    
    @IBOutlet var weightLable: UILabel!
    @IBOutlet var scanLable: UILabel!
    @IBOutlet var weightMeasureLable: UILabel!
    var centralManager: CBCentralManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = .systemGray6 
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance

        // Set the status bar color to match the navigation bar
        navigationController?.navigationBar.barStyle = .black
        
        weightLable.isHidden = true
        weightMeasureLable.isHidden = false
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        weightLable.layer.cornerRadius = 20
        weightLable.layer.masksToBounds = true
        weightLable.layer.shadowColor = UIColor.gray.cgColor // Shadow color
        weightLable.layer.shadowOffset = CGSize(width: 4, height: 5) // Shadow offset (adjust as needed)
        weightLable.layer.shadowOpacity = 0.7 // Shadow opacity (adjust as needed)
        weightLable.layer.shadowRadius = 4.0 // Shadow radius (adjust as needed)
        
        view.addSubview(weightLable)
    }
    
//    func showConfirmationAlertToGoBackTo(_ targetViewController: UIViewController) {
//        let alertController = UIAlertController(title: "Confirmation", message: "Are you sure you want to go back to the Home?", preferredStyle: .alert)
//
//        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] (_) in
//            if let homeVC = self?.navigationController?.viewControllers.first(where: { $0 is HomeVC }) {
//                self?.navigationController?.popToViewController(homeVC, animated: true)
//            }
//        }
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//
//        // Add the actions to the alert controller
//        alertController.addAction(okAction)
//        alertController.addAction(cancelAction)
//
//        // Present the alert
//        present(alertController, animated: true, completion: nil)
//    }

    @IBAction func BackButtonPressedWeightScale(_ sender: Any) {
        Method.showConfirmationAlertToGoBackTo(from: self, targetViewController: HomeVC())

    }
    
}
extension WeighingScaleVC: CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state{
        case .unknown:
            print("central is unknown")
        case .resetting:
            print("central is resetting")
        case .unsupported:
            print("central is unsupported")
        case .unauthorized:
            print("central is unauthorized")
        case .poweredOff:
            print("central is poweredOff")
        case .poweredOn:
            print("central is poweredOn")
            central.scanForPeripherals(withServices: nil)
            print("Scanning...")
        default:
            print("something wrong with the central")
        }
    }

//    func showOverlayWithFinalReading(finalReading: String) {
//        // Create the overlay view
//        let overlayView = UIView(frame: self.view.bounds)
//        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.6) // Semi-transparent black background
//
//        // Create a label for the final reading
//        let label = UILabel()
//        label.text = "Final Reading: \(finalReading)"
//        label.textColor = UIColor.white
//        label.textAlignment = .center
//        label.frame = CGRect(x: 20, y: 100, width: self.view.frame.width - 40, height: 40)
//
//        // Create an "OK" button
//        let okButton = UIButton(type: .system)
//        okButton.setTitle("OK", for: .normal)
//        okButton.setTitleColor(UIColor.white, for: .normal)
//        okButton.frame = CGRect(x: 20, y: 160, width: self.view.frame.width - 40, height: 40)
//        okButton.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
//
//        // Add the label and button to the overlay view
//        overlayView.addSubview(label)
//        overlayView.addSubview(okButton)
//
//        // Add the overlay view to the current view controller's view
//        self.view.addSubview(overlayView)
//    }
//
//    @objc func okButtonTapped() {
//        // Perform any necessary actions when the "OK" button is tapped
//        navigateToHomeScreen()
//    }
//
//    func hideOverlay() {
//        // Remove the overlay view from the view hierarchy
//        if let overlayView = self.view.subviews.first(where: { $0.backgroundColor == UIColor.black.withAlphaComponent(0.6) }) {
//            overlayView.removeFromSuperview()
//        }
//    }
//    func navigateToHomeScreen() {
//        // Replace this with your navigation code to go to the Home screen
//        // For example, if you're using a UINavigationController:
//        if let navigationController = self.navigationController {
//            navigationController.popToRootViewController(animated: true)
//        }
//    }


    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //print(peripheral)
        //print(advertisementData)
        if peripheral.identifier == UUID(uuidString: "50BC6155-F71B-AC6A-5264-EC08D9391B9F"){
            //print("The manufacturer data:\(manufactureData)")
            if let manufactureData = advertisementData["kCBAdvDataManufacturerData"] as? Data{
                let hexstring = Conversion.byteArrayToHexString([UInt8](manufactureData))
                print(hexstring)
                
                
                let startIndex = hexstring.index(hexstring.startIndex, offsetBy: 30)
                let endIndex = hexstring.index(hexstring.startIndex, offsetBy: 38)
                
                //AO => unstable weight
                if hexstring.contains(WeightBLEReadingoptions.unstableReading.rawValue) {
                    
                    let unstableHexReading = String(hexstring[startIndex..<endIndex])
                    let unstableDecimalReading = Conversion.hexadecimalToDecimal(String(unstableHexReading))!
                    let exactUnstableReading = Double(unstableDecimalReading) / Double(10)
                    scanLable.text = "Measuring"
                    weightLable.isHidden = false
                    weightLable.text = "\(String(exactUnstableReading)) Kg"
                    
                }
                
                if hexstring.contains(WeightBLEReadingoptions.finalReading.rawValue){
                    central.stopScan()
                    let finalHexReading = String(hexstring[startIndex..<endIndex])
                    print("The extracted Part :\(finalHexReading)")
                    let finalDecimalReading = Conversion.hexadecimalToDecimal(finalHexReading)!
                    print("The decimal value :\(finalDecimalReading)")
                    let finalWeight = Double(finalDecimalReading) / Double(10)
                    print("The exactWeight:\(finalWeight)")
                    
                    weightLable.isHidden = true
                    weightLable.text = "\(String(finalWeight)) Kg"
                    scanLable.text = "Weight Measured Successfully."
                    weightLable.backgroundColor = .systemGreen
                    weightMeasureLable.isHidden = true
                    //AlertAfterReading.alertReadingHasTaken(title: "Weight Measured Successfully", message: "The weight has been measured successfully.", viewController: self)
                    //alert popup with reading
                    //showOverlayWithFinalReading(finalReading: String(finalWeight))
                    if let popupViewController = storyboard?.instantiateViewController(identifier: "WeightScalePopupVC") as? WeightScalePopupVC{
                        popupViewController.finalReading = "\(String(finalWeight)) Kg"
                        popupViewController.modalPresentationStyle = .overCurrentContext
                        self.present(popupViewController, animated: true)
                    }
                }
            }
        }
    }
}
