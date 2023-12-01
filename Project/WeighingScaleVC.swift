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

class WeighingScaleVC: UIViewController {
    
    //MARK: Properties
    var centralManager: CBCentralManager!
    
    //MARK: IBOutlets
    @IBOutlet var weightLable: UILabel!
    @IBOutlet var scanLable: UILabel!
    @IBOutlet var weightMeasureLable: UILabel!
    
    //MARK: OverrideViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    func initialSetup() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
        setUpVavigationBar()
        configureLable(lableName: weightLable)
        configureLable(lableName: weightLable, bool: true)
        weightMeasureLable.isHidden = false
    }
    
    //MARK: - SetUpVavigationBar
    func setUpVavigationBar() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = .systemGray6
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        // Set the status bar color to match the navigation bar
        navigationController?.navigationBar.barStyle = .black
    }
    
    //MARK: - configureWeightLable
    func configureLable(lableName: UILabel, bool: Bool = true) {
        lableName.layer.cornerRadius = 20
        lableName.layer.masksToBounds = true
        lableName.layer.shadowColor = UIColor.gray.cgColor // Shadow color
        lableName.layer.shadowOffset = CGSize(width: 4, height: 5) // Shadow offset (adjust as needed)
        lableName.layer.shadowOpacity = 0.7 // Shadow opacity (adjust as needed)
        lableName.layer.shadowRadius = 4.0 // Shadow radius (adjust as needed)
        lableName.isHidden = bool
        lableName.isHidden = bool
    }
    
    //MARK: - IBAction
    @IBAction func BackButtonPressedWeightScale(_ sender: Any) {
        Method.showConfirmationAlertToGoBackTo(from: self)
    }
}

//MARK: - Extension
extension WeighingScaleVC: CBCentralManagerDelegate {
    //MARK: - centralMangerDidUpdateState
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
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
    
    //MARK: - didDiscoverPeripheral
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //print(peripheral)
        //print(advertisementData)
        if peripheral.identifier == UUID(uuidString: "50BC6155-F71B-AC6A-5264-EC08D9391B9F") {
            //print("The manufacturer data:\(manufactureData)")
            if let manufactureData = advertisementData["kCBAdvDataManufacturerData"] as? Data {
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
                
                //AA => stable weight
                if hexstring.contains(WeightBLEReadingoptions.finalReading.rawValue) {
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
                    if let popupViewController = storyboard?.instantiateViewController(identifier: "WeightScalePopupVC") as? WeightScalePopupVC {
                        popupViewController.finalReading = "\(String(finalWeight)) Kg"
                        popupViewController.modalPresentationStyle = .overCurrentContext
                        self.present(popupViewController, animated: true)
                    }
                }
            }
        }
    }
}
