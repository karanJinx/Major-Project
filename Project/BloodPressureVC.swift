//
//  BloodPressureVC.swift
//  Project
//
//  Created by Humworld Solutions Private Limited on 07/09/23.
//

import Foundation
import UIKit
import CoreBluetooth

class BloodPressureVC: UIViewController{
    @IBOutlet var systolicLable: UILabel!
    @IBOutlet var diastolicLable: UILabel!
    @IBOutlet var pulseLable: UILabel!
    @IBOutlet var scanningLable: UILabel!
    
    var bloodPressureServiceUUID = CBUUID(string: "0xFFF0")
    var bloodPressureCharacteristicUUID1 = CBUUID(string: "0xFFF1") // Notify
    var bloodPressureCharacteristicUUID2 = CBUUID(string: "0xFFF2") //write no response
    var bloodPressureCharacteristicUUID3 = CBUUID(string: "0xFFF6") // Read,Notify,write no response
    
    var characteristic_writeWithoutResponse: CBCharacteristic!
    
    var centralManager: CBCentralManager!
    var myPeripheral: CBPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
}
extension BloodPressureVC: CBCentralManagerDelegate,CBPeripheralDelegate{
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
            scanningLable.text = "The Central Bluetooth is PoweredOff."
        case .poweredOn:
            print("The central is PoweredOn")
            //scanningLable.text = "The central Bluetooth is PoweredOn."
            //centralManager.scanForPeripherals(withServices: [bloodPressureServiceUUID])
            centralManager.scanForPeripherals(withServices: nil)
        default:
            print("Something wrong with the central")
        }
    }
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
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected")
        scanningLable.text = "Device Connected Successfully."
//        peripheral.discoverServices([bloodPressureServiceUUID])
        peripheral.discoverServices(nil)
        
    }
    
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
    
    
    
    /// To discover the characteristics of the services
    /// - Parameters:
    ///   - peripheral: connected to BLE device
    ///   - service: writing and reading the serivces
    ///   - error: swift error
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else{return}
        
        for characteristic in characteristics {
            print("The characteristic of the service:\(characteristic)")
            if characteristic.properties.contains(.writeWithoutResponse){
                characteristic_writeWithoutResponse = characteristic
                
                let commandBytes: [UInt8] = [0xFD, 0xFD ,0xFA ,0x09, 0x13, 0x0B, 0x13, 0x12, 0x01, 0x14, 0x0D, 0x0A]
                let commandSend = Data(commandBytes)
                peripheral.writeValue(commandSend, for: self.characteristic_writeWithoutResponse, type: .withoutResponse)
            }
//            if characteristic.properties.contains(.read){
//                peripheral.readValue(for: characteristic)
//                print("\(characteristic.uuid) contains the read property")
//            }
            if characteristic.properties.contains(.notify){
                peripheral.setNotifyValue(true, for: characteristic)
                print("\(characteristic.uuid) contains the notify property")
            }
           
            
        }
    }
    
    
    func byteToHexadecimal(data: [UInt8], addSpace: Bool) -> String? {
        if data.isEmpty { return nil }
        var hexString = ""
        for byte in data {
            let hex = String(format: "%02X", byte)
            hexString += hex
            if addSpace {
                hexString += " "
            }
        }
        return hexString.trimmingCharacters(in: .whitespaces)
    }
    
    func hexadecimalToDecimal(_ hexString: String) -> Int? {
        var result: UInt64 = 0
        let scanner = Scanner(string: hexString)
        scanner.scanHexInt64(&result)
        return Int(result)
    }
    
    func getPairsFromHexString(data: [UInt8]?) -> [String]? {
        guard let data = data, !data.isEmpty else {
            return nil
        }
        var pairs = [String]()
        for byte in data {
            var hex = String(byte, radix: 16)
            if hex.count == 1 {
                hex = "0" + hex
            }
            pairs.append(hex)
        }
        return pairs
    }

    
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
        case bloodPressureCharacteristicUUID1:
            if let data = characteristic.value {
                
                let byteArray = [UInt8](data)
                let hexString = byteToHexadecimal(data: byteArray, addSpace: true)!//byteArrayToHexString([UInt8](data))
                let list = [getPairsFromHexString(data: byteArray)]
//                print("The List :\(list)")
                print("Received Data as Hexadecimal: \(hexString)")
                
               
                
                for item in list {
                    if let item = item,item.contains("fb"),item.count >= 5{
                        scanningLable.text = "scanning..."
                        let diastolicreading = item[(item.index(item.startIndex, offsetBy: 4))]
                        print("Diastolic reading: \(hexadecimalToDecimal(String(diastolicreading))!)")
                        diastolicLable.text = "\(hexadecimalToDecimal(String(diastolicreading))!)"
                    }else if item!.contains("a5"){
                        scanningLable.text = "Tap Start"
                    }
                    else if let item = item,item.contains("fc"),item.count >= 6{
                        let systolicReading = item[item.index(item.startIndex, offsetBy: 3)]
                        let diastolicReading = item[item.index(item.startIndex, offsetBy: 4)]
                        let pulseReading = item[item.index(item.startIndex, offsetBy: 5)]
                        
                        print("Systolic reading: \(hexadecimalToDecimal(systolicReading)!)")
                        print("Diastolic reading: \(hexadecimalToDecimal(diastolicReading)!)")
                        print("Pulse reading: \(hexadecimalToDecimal(pulseReading)!)")
                        
                        systolicLable.text = "\(hexadecimalToDecimal(systolicReading)!)"
                        diastolicLable.text = "\(hexadecimalToDecimal(diastolicReading)!)"
                        pulseLable.text = "\(hexadecimalToDecimal(pulseReading)!)"
                        scanningLable.text = "Final Readings"
                        
                    }else if let item = item,item.contains("01") || item.contains("02") || item.contains("03") || item.contains("04") || item.contains("0C"){
                        print("The human heartbeat signal is too small or the pressure drops suddenly")
                        scanningLable.text = "If the measurement is wrong, please wear the CUFF again according to the instruction manual.Keep quiet and re-measure. (Use this sentence for the above 5 items)."
                     }
                    else if let item = item{
                        item.contains("0B")
                        scanningLable.text = "The battery is low, please replace the battery"
                    }
                    


                }
            }

            else {
                print("No value received for Blood Pressure characteristic")
            }
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error writing value to characteristic \(characteristic.uuid): \(error.localizedDescription)")
        } else {
            print("Successfully wrote value to characteristic \(characteristic.uuid)")
            // Check if there's any specific response or state change you should expect from the device.
        }
    }
}
