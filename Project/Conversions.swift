//
//  Conversions.swift
//  Project
//
//  Created by Humworld Solutions Private Limited on 30/10/23.
//

import Foundation
import CoreBluetooth

struct Conversion {
    //MARK: - convertByteArrayToHexString
    /// converting Byte Array to HexString Without seperation
    /// - Parameter byteArray: parameter is array of unsinged integer
    /// - Returns: returns the string of hexadecimal
    static func byteArrayToHexString(_ byteArray: [UInt8]) -> String {
        return byteArray.map { String(format: "%02X", $0) }.joined(separator: "")
    }
    
    //MARK: - convertHexadecimalToDecimal
    /// Converting a hexadecimal to decimal
    /// - Parameter hexString: string of hexadecimal
    /// - Returns: returns the result in integer
    static func hexadecimalToDecimal(_ hexString: String) -> Int? {
        var result: UInt64 = 0
        let scanner = Scanner(string: hexString)
        scanner.scanHexInt64(&result)
        return Int(result)
    }
    
    //MARK: - convertbyteArrayToHexString1
    /// Converting byte array to hexadecimal string
    /// - Parameter byteArray: byte array is the array of unsinged integer
    /// - Returns: returns the array of hexadecimal string in the format of "%02X"
    static func byteArrayToHexString1(_ byteArray: [UInt8]) -> [String] {
        return byteArray.map { String(format: "%02X", $0) }
    }
    
    //MARK: - convertgetPairsFromHexString
    /// getting pairs by converting the array of unsinged integer to array of paired hexstring ,from the hexadecimal string
    /// - Parameter data: array of unsinged Byte array
    /// - Returns: It retruns the paired hexadecimal string
    static func getPairsFromHexString(data: [UInt8]?) -> [String]? {
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
    
    //MARK: - convertbyteToHexadecimal
    /// converting the array of bytearrray to hexadecimal
    /// - Parameters:
    ///   - data: it is the array of byte arrays
    ///   - addSpace: Eeither true or false
    /// - Returns: if the add space is true - space between the hexadecimal string , else the hexadecimal will be without space
    static func byteToHexadecimal(data: [UInt8], addSpace: Bool) -> String? {
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
    
    //MARK: - ReverseHexaDecimal
    static func reverseHexaDecimal(_ hexString: String) -> [String] {
        var hexString = hexString
        if hexString.count % 2 != 0 {
            hexString = "0" + hexString // Add a leading zero if the length is odd
        }
        let firstPartIndex = hexString.index(hexString.startIndex, offsetBy: hexString.count / 2)
        let firstPart = String(hexString[..<firstPartIndex])
        let secondPart = String(hexString[firstPartIndex...])
        
        return [firstPart, secondPart]
    }
    
    //MARK: - FindCharacteristicToDisconnect
    /// Method to find the characteristic for the shutdown of ble device
    /// - Parameters:
    ///   - uuid: uuid is the characteristic for the shutdown(which is writeNoResponse)
    ///   - peripheral: which is the ble device
    /// - Returns: returns the characteristics
    static func findCharacteristic(withUUID uuid: CBUUID, in peripheral: CBPeripheral) -> CBCharacteristic? {
        for service in peripheral.services ?? [] {
            if let characteristic = service.characteristics?.first(where: { $0.uuid == uuid }) {
                print("The characteristi:\(characteristic)")
                return characteristic
            }
        }
        return nil
    }
}
