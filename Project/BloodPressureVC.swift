//
//  BloodPressureVC.swift
//  Project
//
//  Created by Humworld Solutions Private Limited on 07/09/23.
//

import Foundation
import UIKit
import CoreBluetooth

enum bloodPressureReadingOptions: String{
    case measuringReading = "FB"
    case finalReading = "FC"
    case readyToTakeReading = "A5"
    case signalIsTooSmall = "01"
    case noiseInterference = "02"
    case tooLongInflamation = "03"
    case abnormalResult = "04"
    case batteryLow = "0B"
}

class BloodPressureVC: UIViewController{
    //MARK: - IBOutlets
    @IBOutlet var systolicReadingLable: UILabel!
    @IBOutlet var diastolicReadingLable: UILabel!
    @IBOutlet var pulseReadingLable: UILabel!
    @IBOutlet var scanningLable: UILabel!
    @IBOutlet var systolicLable: UILabel!
    @IBOutlet var pulseLable: UILabel!
    @IBOutlet var diastolicMeasuringLable: UILabel!
    
    //MARK: - Properties
    var centralManager: CBCentralManager!
    var myPeripheral: CBPeripheral!
    var characteristic_writeWithoutResponse: CBCharacteristic!
    var bloodPressureServiceUUID = CBUUID(string: "0xFFF0")
    var bloodPressureCharacteristicUUID1 = CBUUID(string: "0xFFF1") // Notify
    var bloodPressureCharacteristicUUID2 = CBUUID(string: "0xFFF2") //write no response
    var bloodPressureCharacteristicUUID3 = CBUUID(string: "0xFFF6") // Read,Notify,write no response
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
    }
    
    //MARK: InitialSetup
    func initialSetUp() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
        setUpNavigationBar()
        systolicLable.isHidden = true
        pulseLable.isHidden = true
        systolicReadingLable.isHidden = true
        pulseReadingLable.isHidden = true
    }
    
    //MARK: - SetUpNavigationBar
    func setUpNavigationBar() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = .systemGray6
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        // Set the status bar color to match the navigation bar
        navigationController?.navigationBar.barStyle = .black
    }
    
    //MARK: - ViewWillDisapper
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Find the characteristic with the shutdown UUID in the discovered services
        if let peripheralBPDevice = myPeripheral{
            if let shutdownCharacteristic = Conversion.findCharacteristic(withUUID: bloodPressureCharacteristicUUID2, in: peripheralBPDevice) {
                // Define the command to be sent
                let commandBytes: [UInt8] = [0xFD, 0xFD, 0xFA, 0x06, 0x0D, 0x0A]
                let commandSend = Data(commandBytes)
                
                // Write the command to the shutdown characteristic without response
                myPeripheral.writeValue(commandSend, for: shutdownCharacteristic, type: .withoutResponse)
            }
        }
    }
    
    //MARK: IBACTION
    @IBAction func backButtonPressedBP(_ sender: Any) {
        Method.showConfirmationAlertToGoBackTo(from: self)
    }
}

//MARK: - Extension
extension BloodPressureVC: CBCentralManagerDelegate, CBPeripheralDelegate {
    
    //MARK: - CentralManagerDidUpdateState
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("The central is Unknown")
        case .resetting:
            print("The central is resetting")
        case .unsupported:
            print("The central is Unsupported")
        case .unauthorized:
            print("The central is Unauthorized")
        case .poweredOff:
            print("The central is PoweredOff")
            scanningLable.text = "The Central Bluetooth is PoweredOff."
        case .poweredOn:
            print("The central is PoweredOn")
            centralManager.scanForPeripherals(withServices: nil)
        default:
            print("Something wrong with the central")
        }
    }
    
    //MARK: - DidDiscoverPeripheral
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let name = peripheral.name{
            if name != "(null)"{
                print("The available peripheral devices:\(peripheral)")
            }
            if name == "Bluetooth BP"{
                central.stopScan()
                self.myPeripheral = peripheral
                self.myPeripheral.delegate = self
                self.centralManager.connect(peripheral,options: nil)
                print("Peripheral successfully connected to the central.....")
                scanningLable.text = "Connecting"
            }
        }
    }
    
    //MARK: - DidConnectPeripheral
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected")
        scanningLable.text = "Device Connected Successfully."
        //        peripheral.discoverServices([bloodPressureServiceUUID])
        peripheral.discoverServices(nil)
        
    }
    
    //MARK: - DidDiscoverServices
    /// To discover the BLE Services
    /// - Parameters:
    ///   - peripheral: connected BLE device
    ///   - error: Swift Error
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {return}
        for service in services {
            print("The services of the bluetooth BP is: \(service)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    //MARK: - DidDiscoverCharacteristics
    /// To discover the characteristics of the services
    /// - Parameters:
    ///   - peripheral: connected to BLE device
    ///   - service: writing and reading the serivces
    ///   - error: swift error
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else{return}
        
        for characteristic in characteristics {
            print("The characteristic of the service:\(characteristic)")
            if characteristic.properties.contains(.writeWithoutResponse) {
                characteristic_writeWithoutResponse = characteristic
                
                let commandBytes: [UInt8] = [0xFD, 0xFD ,0xFA ,0x09, 0x13, 0x0B, 0x13, 0x12, 0x01, 0x14, 0x0D, 0x0A]
                //let commandBytes: [UInt8] = [0xFD, 0xFD ,0xFA, 0x06, 0x0D, 0x0A]
                let commandSend = Data(commandBytes)
                peripheral.writeValue(commandSend, for: self.characteristic_writeWithoutResponse, type: .withoutResponse)
            }
            //            if characteristic.properties.contains(.read){
            //                peripheral.readValue(for: characteristic)
            //                print("\(characteristic.uuid) contains the read property")
            //            }
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
                print("\(characteristic.uuid) contains the notify property")
            }
        }
    }
    
    //MARK: - DidUpdateValueForCharacteristic
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if let data = characteristic.value {
            let byteArray = [UInt8](data)
            let hexString = [Conversion.byteArrayToHexString1([UInt8](byteArray))]
            //                let list = [Conversion.getPairsFromHexString(data: byteArray)]
            //                print("The List :\(list)")
            print("Received Data as Hexadecimal: \(hexString)")
            
            for item in hexString {
                if item.count >= 6{
                    if item.contains(bloodPressureReadingOptions.measuringReading.rawValue) {
                        scanningLable.text = "Measuring"
                        let diastolicreading = item[item.index(item.startIndex, offsetBy: 4)]
                        
                        DispatchQueue.main.async {
                            self.diastolicMeasuringLable.text = "Measuring Values"
                        }
                        let diastolic_hex = Int(Conversion.hexadecimalToDecimal(diastolicreading)!)
                        print("Diastolic reading: \(diastolic_hex)")
                        diastolicReadingLable.text = String(diastolic_hex)
                    }
                    else if item.contains(bloodPressureReadingOptions.readyToTakeReading.rawValue) {
                        scanningLable.text = "Press Start in device"
                    }
                    else if item.contains(bloodPressureReadingOptions.finalReading.rawValue) {
                        let systolicReading = item[item.index(item.startIndex, offsetBy: 3)]
                        let diastolicReading = item[item.index(item.startIndex, offsetBy: 4)]
                        let pulseReading = item[item.index(item.startIndex, offsetBy: 5)]
                        
                        
                        let systolic_hex = Int(Conversion.hexadecimalToDecimal(systolicReading)!)
                        print("systolic reading: \(systolic_hex)")
                        systolicReadingLable.text = String(systolic_hex)
                        
                        let diastolic_hex = Int(Conversion.hexadecimalToDecimal(diastolicReading)!)
                        print("Diastolic reading: \(diastolic_hex)")
                        diastolicReadingLable.text = String(diastolic_hex)
                        
                        DispatchQueue.main.async {
                            self.diastolicMeasuringLable.text = "Diastolic Reading"
                        }
                        
                        let pulse_hex = Int(Conversion.hexadecimalToDecimal(pulseReading)!)
                        print("Diastolic reading: \(pulse_hex)")
                        pulseReadingLable.text = String(pulse_hex)
                        
                        systolicLable.isHidden = false
                        systolicReadingLable.isHidden = false
                        
                        pulseLable.isHidden  = false
                        pulseReadingLable.isHidden = false
                        
                        scanningLable.text = "Final Readings"
                        scanningLable.textColor = .systemGreen
                        
                        if let popViewcontroller = storyboard?.instantiateViewController(withIdentifier: "BloodPressurePopupVC") as? BloodPressurePopupVC{
                            popViewcontroller.systolicFinalreading = String(systolic_hex)
                            popViewcontroller.diastolicFinalreading = String(diastolic_hex)
                            popViewcontroller.pulseFinalreading = String(pulse_hex)
                            popViewcontroller.modalPresentationStyle = .overCurrentContext
                            self.present(popViewcontroller, animated: true)
                        }
                        
                        //AlertAfterReading.alertReadingHasTaken(title: "Reading Measured Successfully", message: "Blood Pressure has been Measured successfully", viewController: self)
                        
                    }else if item.contains(bloodPressureReadingOptions.signalIsTooSmall.rawValue) || item.contains(bloodPressureReadingOptions.noiseInterference.rawValue) || item.contains(bloodPressureReadingOptions.tooLongInflamation.rawValue) || item.contains(bloodPressureReadingOptions.abnormalResult.rawValue) || item.contains("0C") || item.contains("05"){
                        print("The human heartbeat signal is too small or the pressure drops suddenly")
                        scanningLable.text = "If the measurement is wrong, please wear the CUFF again according to the instruction manual.Keep quiet and re-measure. (Use this sentence for the above 5 items)."
                        diastolicMeasuringLable.isHidden = true
                        diastolicReadingLable.isHidden = true
                    }
                    else if item.contains(bloodPressureReadingOptions.batteryLow.rawValue){
                        scanningLable.text = "The battery is low, please replace the battery"
                    }
                }
            }
        }
        else {
            print("No value received for Blood Pressure characteristic")
        }
        
    }
    //MARK: - DiddidWriteValueForcharacteristic
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error writing value to characteristic \(characteristic.uuid): \(error.localizedDescription)")
        } else {
            print("Successfully wrote value to characteristic \(characteristic.uuid)")
        }
    }
}
