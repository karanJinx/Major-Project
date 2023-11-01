//
//  EcgVC.swift
//  Project
//
//  Created by Humworld Solutions Private Limited on 07/09/23.
//

import Foundation
import UIKit
import CoreBluetooth

class EcgVC: UIViewController{
    var centralManager: CBCentralManager!
    var myPeripheral: CBPeripheral!
    var notify_characteristic: CBCharacteristic!
    var read_characteristic: CBCharacteristic!
    var write_characteristic: CBCharacteristic!
    var writeWithoutResponse_characteristic: CBCharacteristic!
    
    //    var ECGService_1 = CBUUID(string: "FE59")
    //    var service1_characteristic1 = CBUUID(string: "8EC90001-F315-4F60-9FB8-838830DAEA50") // Notify,Write
    //    var service1_characteristic2 = CBUUID(string: "8EC90002-F315-4F60-9FB8-838830DAEA50") // Read,writeWithoutResponse
    
    var ECGService_2 = CBUUID(string: "14839AC4-7D7E-415C-9A42-167340CF2339")
    var service2_characteristic1 = CBUUID(string: "8B00ACE7-EB0B-49B0-BBE9-9AEE0A26E1A3") //Read,Write,WriteWithoutResponse
    var service2_characteristic2 = CBUUID(string: "0734594A-A8E7-4B1A-A6B1-CD5243059A57")//Notify,Read
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let peripheralECGDevice = myPeripheral{
            if let shutdownCharacteristic = Conversion.findCharacteristic(withUUID: service2_characteristic1, in: peripheralECGDevice){
                let commandBytes:[UInt8] = [0xA5,0x09,~0x09, 0x00, 0x00, 0x01, 0x00, 0x04,0x05]
                let commandSend = Data(commandBytes)
                myPeripheral.writeValue(commandSend, for: shutdownCharacteristic, type: .withoutResponse)
            }
        }
        
    }
    
    @IBAction func backButtonPressedECG(_ sender: Any) {
        Method.showConfirmationAlertToGoBackTo(from: self, targetViewController: HomeVC())
    }
    
    
    
}
extension EcgVC:CBCentralManagerDelegate,CBPeripheralDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state{
        case .unknown:
            print("Central is unknown")
        case .resetting:
            print("Central is resetting")
        case .unsupported:
            print("Central is unsupported")
        case .unauthorized:
            print("Central is unauthorized")
        case .poweredOff:
            print("Central is poweredOff")
        case .poweredOn:
            print("Central is poweredOn")
            centralManager.scanForPeripherals(withServices: nil)
        @unknown default:
            print("Central is default")
            
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let pname = peripheral.name ?? ""
        if pname == "BP2 1840"{
            central.stopScan()
            self.myPeripheral = peripheral
            self.myPeripheral.delegate = self
            
            self.centralManager.connect(peripheral)
            print("Connecting to the peripheral")
        }
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
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
    //function to find the crc and writing the command
    func writeDataWithCRC(commandBytes: [UInt8], peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            // Calculate the CRC
            let dataSize = UInt32(commandBytes.count)
            let dataPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: commandBytes.count)
            dataPointer.initialize(from: commandBytes, count: commandBytes.count)
            let crcResult = crc8_compute(dataPointer, dataSize, 0x00)
            dataPointer.deallocate()
            
            // Append the CRC byte to the commandBytes
            var bytesWithCRC = commandBytes
            bytesWithCRC.append(crcResult)
            
            // Convert the array to Data
            let dataToWrite = Data(bytesWithCRC)
            
            // Check if the characteristic supports writeWithoutResponse
            if characteristic.properties.contains(.writeWithoutResponse) {
                // Perform the write operation
                peripheral.writeValue(dataToWrite, for: characteristic, type: .withoutResponse)
                print("Write success")
            } else {
                print("Characteristic does not support writeWithoutResponse.")
            }
        }
        
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics{
            for characteristic in characteristics {
                // print("The characteristics:\(characteristic)")
                if characteristic.uuid == service2_characteristic2{
                    notify_characteristic = characteristic
                    peripheral.setNotifyValue(true, for: notify_characteristic)
                    print("notify success")
                }
                
                if characteristic.uuid == service2_characteristic1{
                    writeWithoutResponse_characteristic = characteristic
                    
                    let calendar = Calendar.current
                    let components = calendar.dateComponents([.year,.month,.day,.hour,.minute,.second], from: Date())
                    let year = UInt16(components.year!)
                    let month = UInt8(components.month!)
                    let day = UInt8(components.day!)
                    let hour = UInt8(components.hour!)
                    let minute = UInt8(components.minute!)
                    let second = UInt8(components.second!)
                    
                    let yearHexString = String(format: "%2X", year)
                    print(yearHexString)
                    let yearInput = Conversion.reverseHexaDecimal(yearHexString)
                    print(yearInput)
                    print("Year first part:\(yearInput[0])")
                    print("Year second part:\(yearInput[1])")
                    let monthHexString =  String(format: "%02X", month)
                    print(monthHexString)
                    let dayHexString = String(format: "%02X", day)
                    print(dayHexString)
                    let hourHexString = String(format: "%02X", hour)
                    print(hourHexString)
                    let minuteHexString = String(format: "%02X", minute)
                    print(minuteHexString)
                    let secondHexString = String(format: "%02X", second)
                    print(secondHexString)
                    
                    //Writing Time
                    //let commandBytes: [UInt8] = [0xA5, 0xEC, ~0xEC, 0x00, 0x00, 0x07, 0x00, 0xE7, 0x07, 0x0A, 0x19, 0x12, 0x05, 0x32, 0x12]
                    let commandBytes: [UInt8] = [0xA5, 0xEC, ~0xEC, 0x00, 0x00, 0x07, 0x00, UInt8(yearInput[1],radix: 16)!, UInt8(yearInput[0],radix: 16)!, UInt8(monthHexString,radix: 16)!, UInt8(dayHexString,radix: 16)!, UInt8(hourHexString,radix: 16)!, UInt8(minuteHexString,radix: 16)!, UInt8(secondHexString,radix: 16)!]
                    self.writeDataWithCRC(commandBytes: commandBytes, peripheral: peripheral, characteristic: writeWithoutResponse_characteristic)
                    //                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                    //
                    //                        let commandSend = Data(commandBytes)
                    //                        peripheral.writeValue(commandSend, for: self.writeWithoutResponse_characteristic, type: .withoutResponse)
                    //                        print("write success")
                    //                    }
                    
                    //writing swithcing device
                    let commandBytes1: [UInt8] = [0xA5, 0x09, ~0x09, 0x00, 0x01, 0x01,0x00, 0x01]
                    self.writeDataWithCRC(commandBytes: commandBytes1, peripheral: peripheral, characteristic: self.writeWithoutResponse_characteristic)
                    
                    //                    writing real time data
                    let commandBytes2: [UInt8] = [0xA5, 0x08, ~0x08, 0x00, 0x02, 0x00, 0x00]
                    self.writeDataWithCRC(commandBytes: commandBytes2, peripheral: peripheral, characteristic: self.writeWithoutResponse_characteristic)
                    //
                    ////                    //writing
                    //                        let commandBytes3: [UInt8] = [0xA5, 0x03, ~0x03, 0x00, 0x03, 0x00, 0x00]
                    //                        self.writeDataWithCRC(commandBytes: commandBytes3, peripheral: peripheral, characteristic: self.writeWithoutResponse_characteristic)
                    
                    //                    //writing
                    //                        let commandBytes4: [UInt8] = [0xA5, 0x03, ~0x03, 0x00, 0x04, 0x00, 0x00] // file details
                    //                        self.writeDataWithCRC(commandBytes: commandBytes4, peripheral: peripheral, characteristic: self.writeWithoutResponse_characteristic)
                    
                }
                
                
                //                if characteristic.properties.contains(.notify){
                //                    print("Notify:\(characteristic)")
                //                }
                //                if characteristic.properties.contains(.read){
                //                    print("Read:\(characteristic)")
                //                }
                //                if characteristic.properties.contains(.write){
                //                    print("Write:\(characteristic)")
                //                }
                //                if characteristic.properties.contains(.writeWithoutResponse){
                //                    print("WriteWithoutResponse:\(characteristic)")
                //                }
            }
        }
        
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        //print("the characteristic:\(characteristic)")
        if let value = characteristic.value {
            print("The value:\(value)")
            let value_bytesToHex = Conversion.byteArrayToHexString1([UInt8](value))//getPairsFromHexString(data: [UInt8](value))
            print("The Value Hex:\(value_bytesToHex)")
            //print("Data received")
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error writing characteristic: \(error.localizedDescription)")
            return
        }
        if let value = characteristic.value {
            print("Characteristic \(value) written")
            
        } else {
            print("Characteristic value is empty")
        }
    }
}
