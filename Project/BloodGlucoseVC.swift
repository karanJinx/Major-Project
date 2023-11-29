//
//  BloodGlucoseVC.swift
//  Project
//
//  Created by Humworld Solutions Private Limited on 07/09/23.
//

import Foundation
import UIKit
import CoreBluetooth

class BloodGlucoseVC:UIViewController{
    @IBOutlet var statusLable: UILabel!
    @IBOutlet var finalReadingsLable: UILabel!
    
    
    var service1UUID = CBUUID(string: "0x0003CDD0-0000-1000-8000-00805F9B0131")
    var service1_Characteristic_1 = CBUUID(string: "0x0003CDD1-0000-1000-8000-00805F9B0131") // notify -> giving the byte when the central is disconnected from the peripheral
    var service1_Characteristic_2 = CBUUID(string: "0x0003CDD2-0000-1000-8000-00805F9B0131") // writeWithoutResponse
    
    var bloodGlucoMeterServiceUUID = CBUUID(string: "0xFEE7")//Device Information,FEE7,0003CDD0-0000-1000-8000-00805F9B0131
    var bloodGlucoMeterCharacteristicUUID1 = CBUUID(string: "0xFEC7") //write
    var bloodGlucoMeterCharacteristicUUID2 = CBUUID(string: "0xFEC8")
    var bloodGlucoMeterCharacteristicUUID3 = CBUUID(string: "0xFEC9") //read
    
    var centralManager : CBCentralManager!
    var myPeripheral: CBPeripheral!
    
    var characteristic_notify : CBCharacteristic!
    var characteristic_read : CBCharacteristic!
    var characteristic_write : CBCharacteristic!
    var characteristic_writeWithoutResponse : CBCharacteristic!
    var characteristic_WriteWithResponse : CBCharacteristic!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = .systemGray6 
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance

        // Set the status bar color to match the navigation bar
        navigationController?.navigationBar.barStyle = .black
        
        finalReadingsLable.isHidden = true
        finalReadingsLable.layer.cornerRadius = 20
        finalReadingsLable.layer.masksToBounds = true
        finalReadingsLable.layer.shadowColor = UIColor.gray.cgColor // Shadow color
        finalReadingsLable.layer.shadowOffset = CGSize(width: 4, height: 5) // Shadow offset (adjust as needed)
        finalReadingsLable.layer.shadowOpacity = 0.7 // Shadow opacity (adjust as needed)
        finalReadingsLable.layer.shadowRadius = 4.0 // Shadow radius (adjust as needed)
        centralManager = CBCentralManager(delegate: self, queue: nil)
        view.addSubview(finalReadingsLable)
        
    }

    @IBAction func backButtonPressedBG(_ sender: Any) {
        Method.showConfirmationAlertToGoBackTo(from: self)
    }
}
extension BloodGlucoseVC: CBCentralManagerDelegate,CBPeripheralDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state{
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
        case .poweredOn:
            print("The central is PoweredOn")
            centralManager.scanForPeripherals(withServices: nil,options: nil)
        default:
            print("Something wrong with the central")
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)
        let pname = peripheral.name ?? ""
        if pname.contains("Viva"){
            central.stopScan()
            self.myPeripheral = peripheral
            self.myPeripheral.delegate = self
            self.centralManager.connect(peripheral,options: nil)
            print("Connecting to the periphral")
        }
//        else if pname == "VivaGuard"{
//            central.stopScan()
//            self.myPeripheral = peripheral
//            self.myPeripheral.delegate = self
//            self.centralManager.connect(peripheral,options: nil)
//            print("Connecting to the periphral")
//        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        statusLable.text = "Connected Successfully"
        print("Connected")
        peripheral.discoverServices(nil)
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services{
            for service in services {
                print(service)
                
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics{
            for characteristic in characteristics {
                print(characteristic)
                //                if characteristic.uuid == bloodGlucoMeterCharacteristicUUID3{
                //                    characteristic_read = characteristic
                //                    peripheral.readValue(for: characteristic_read)
                //                }
                
                if characteristic.uuid == service1_Characteristic_1{
                    characteristic_notify = characteristic
                    peripheral.setNotifyValue(true, for: characteristic_notify)
                }
                
                if (characteristic.uuid == service1_Characteristic_2){
                    characteristic_writeWithoutResponse = characteristic
                    //let commandBytes: [UInt8] = [0x7B,0x01,0x10,0x01,0x20,0x77,0x55,0x00,0x00,0x01,0x0B,0x0B,0x04,0x7D] // SerialNumber
                    // let commandAA: [UInt8] = [0x7B, 0x01, 0x10, 0x01, 0x20, 0xAA, 0x55, 0x00, 0x00, 0x02 ,0x01, 0x0D, 0x08, 0x7D] // Unit AA
                    //                    let commandHistory: [UInt8] = [0x7B, 0x01 ,0x10, 0x01, 0x20, 0xDD, 0x55, 0x00, 0x00, 0x03, 0x0A, 0x06, 0x0C, 0x7D]
                    //                    let commandhis = Data(commandHistory)
                    let commandBytes_stripIn : [UInt8] = [0x7B,0x01,0x10,0x01,0x20,0x12,0x99,0x00,0x00,0x0C,0x05,0x04,0x07,0x7D]
                    let command = Data(commandBytes_stripIn)
                    myPeripheral.writeValue(command, for: characteristic_writeWithoutResponse, type: .withoutResponse)
                }
                
                
                //static method to write date and time
                //                if characteristic.uuid == service1_Characteristic_2{
                //                    characteristic_writeWithoutResponse = characteristic
                //                    let commandBytes: [UInt8] = [0x7B, 0x01, 0x10, 0x01, 0x20, 0x44, 0x66 ,0x00 ,0x06 ,0x10 ,0x07 ,0x0B, 0x0F, 0x32, 0x2A, 0x07,0x04, 0x03, 0x08, 0x7D]
                //                    let commandSend = Data(commandBytes)
                //                    peripheral.writeValue(commandSend, for: characteristic_writeWithoutResponse, type: .withoutResponse)
                //                }
                
                if characteristic.uuid == service1_Characteristic_2{
                    
                    characteristic_writeWithoutResponse = characteristic
                    
                    let calendar = Calendar.current
                    let components = calendar.dateComponents([.year,.month,.day,.hour,.minute,.second], from: Date())
                    let year = UInt8(components.year! % 100)
                    let month = UInt8(components.month!)
                    let day = UInt8(components.day!)
                    let hour = UInt8(components.hour!)
                    let minute = UInt8(components.minute!)
                    let second = UInt8(components.second!)
                    
                    let yearHexString = String(format: "%2X", year)
                    let monthHexString =  String(format: "%02X", month)
                    let dayHexString = String(format: "%02X", day)
                    let hourHexString = String(format: "%02X", hour)
                    let minuteHexString = String(format: "%02X", minute)
                    let secondHexString = String(format: "%02X", second)
                    
                    
                    let commandBytes: [UInt8] = [0x01, 0x10, 0x01, 0x20, 0x44, 0x66 ,0x00 ,0x06 ,UInt8(yearHexString,radix: 16)!,UInt8(monthHexString,radix: 16)!,UInt8(dayHexString,radix: 16)!, UInt8(hourHexString,radix: 16)!, UInt8(minuteHexString,radix: 16)!, UInt8(secondHexString,radix: 16)!]
                    print("the command bytes:\(commandBytes)")
                    
                    //let commandBytes: [UInt8] = [0x01, 0x10, 0x01, 0x20, 0x44, 0x66 ,0x00 ,0x06 ,0x10 ,0x07 ,0x0B, 0x0F, 0x32, 0x2A]
                    let datalenght = UInt32(commandBytes.count)
                    
                    let dataPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: commandBytes.count)
                    dataPointer.initialize(from: commandBytes, count: commandBytes.count)
                    
                    let crcResult = s_Crc16Bit(dataPointer,datalenght)
                    dataPointer.deallocate()
                    
                    let o1 = Int((crcResult >> 8) & 0xFF)
                    let o2 = Int(crcResult & 0xFF)
                    
                    print(String(format: "CRC Result: %02X", (o1 >> 4) & 0xFF))
                    print(String(format: "CRC Result: %02X", o1 & 0xF))
                    print(String(format: "CRC Result: %02X", (o2 >> 4) & 0xFF))
                    print(String(format: "CRC Result: %02X", o2 & 0xF))
                    print("The crc resrtt:\(crcResult)")
                    
                    var crcBytes = [UInt8](repeating: 0, count: 4)
                    crcBytes[0] = UInt8((crcResult >> 12) & 0xF)
                    crcBytes[1] = UInt8((crcResult >> 8) & 0xF)
                    crcBytes[2] = UInt8((crcResult >> 4) & 0xF)
                    crcBytes[3] = UInt8(crcResult & 0xF)
                    print("The crc Bytes :\(crcBytes)")
                    
                    let header: [UInt8] = [0x7B]
                    let footer: [UInt8] = [0x7D]
                    
                    let mergedByteArray = header + commandBytes + crcBytes + footer
                    print("the mergedByteArray:\(mergedByteArray)")
                    let mergedHexadecimal = Conversion.byteArrayToHexString1([UInt8](mergedByteArray))
                    print("The mergerHex:\(mergedHexadecimal)")
                    
                    let command = Data(mergedByteArray)
                    
                    print("The command:\(command)")
                    peripheral.writeValue(command, for: characteristic_writeWithoutResponse, type: .withoutResponse)
                    
                    //                    print("My commandByte:\(commandBytes)")
                    //                    let command2 = byteArrayToHexString([UInt8](command))
                    //                    print("My commandByte2:\(command2)")
                    
                    
                    
                }
                
            }
        }
    }
//    func showPopupWithFinalReading(finalReading: String) {
//        let alert = UIAlertController(title: "Final Reading", message: "Your final reading is \(finalReading)", preferredStyle: .alert)
//
//        // Create an "OK" action
//        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
//            // Navigate to the Home screen
//            self?.navigateToHomeScreen()
//        }
//
//        alert.addAction(okAction)
//
//        // Present the alert
//        present(alert, animated: true, completion: nil)
//    }
//
//    func navigateToHomeScreen() {
//        // Replace this with your navigation code to go to the Home screen
//        // For example, if you're using a UINavigationController:
//        if let navigationController = self.navigationController {
//            navigationController.popToRootViewController(animated: true)
//        }
//    }

    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let value = characteristic.value {
            //let byteArray = [UInt8](value)
            print("Data received")
            print(value as NSData)
            let values = Conversion.getPairsFromHexString(data: [UInt8](value))!
            print(values)
            if values.count >= 8 {
                let startIndex = values.index(values.startIndex, offsetBy: 1)
                let stopIndex = values.index(values.startIndex, offsetBy: 5)
                let indexValues = values[startIndex..<stopIndex]
                print("the indexValueds:\(indexValues)")
            }
            if values.first == "7b" && values.last == "7d" {
                if values[1] == "01" && values[2] == "20" && values[3] == "01" && values[4] == "10" {
                    if values[5] == "12" && values[6] == "66" {
                        if values[9] == "11" {
                            print("Strip is inserted")
                            statusLable.text = "Strip is inserted"
                        } else if values[9] == "22" {
                            statusLable.text = "Ready for the test, keep blood in the strip"
                            print("Ready for the test, keep blood in the strip")
                        } else if values[9] == "33" {
                            statusLable.text = "Please Wait"
                            print("Please Wait")
                        } else if values[9] == "44" {
                            let index10 = values[10]
                            let index10HexValue = Conversion.hexadecimalToDecimal(index10)
                            let index11 = values[11]
                            let index11Hexvalue = Conversion.hexadecimalToDecimal(index11)
                            
                            let resultInDecimal = String(index10HexValue!) + String(index11Hexvalue!)
                            print("The Final Reading:\(resultInDecimal)")
                            //                            let resultInDecimal = UInt8(resultInHex,radix: 16)!
                            finalReadingsLable.isHidden = false
                            statusLable.text = "Final Readings"
                            finalReadingsLable.text = "\(resultInDecimal) mg/dL"
                            finalReadingsLable.backgroundColor = .systemGreen
                            //AlertAfterReading.alertReadingHasTaken(title: "Reading Measured Successfully", message: "Blood glucose level has been Measured successfully",viewController: self)
                            if let popViewcontroller = storyboard?.instantiateViewController(withIdentifier: "BloodGlucosePopupVC") as? BloodGlucosePopupVC{
                                popViewcontroller.finalReadings = String("\(resultInDecimal) mg/dL")
                                popViewcontroller.modalPresentationStyle = .overCurrentContext
                                self.present(popViewcontroller, animated: true)
                            }
                            
                        } else if values[9] == "55" {
                            statusLable.text = "Invalid strip"
                            print("Invalid strip")
                        }
                    } else if values[5] == "d2" && values[6] == "66" {
                        if values[9] == "0b" {
                            statusLable.text = "Bluetooth disconnected"
                            print("Bluetooth disconnected")
                        }
                    } else if values[5] == "44" && values[6] == "99"{
                        print("Time setted in the BG device")
                    } else {
                        print("Other protocols")
                    }
                }else{
                    print("Other address")
                }
            }else{
                print("Other header and footer")
            }
            
            
            //print("The value :\(getPairsFromHexString(data: byteArray)!)")
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            // Handle the error
            print("Error writing value to characteristic \(characteristic.uuid): \(error.localizedDescription)")
        } else {
            // Write operation successful
            print("Successfully wrote value to characteristic \(characteristic.uuid)")
        }
    }
}
