//
//  BLE.swift
//  Bluetooth
//
//  Created by Jiahe Li on 27/10/2017.
//  Copyright © 2017 Gellert. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLEManager {
    var manager: CBCentralManager?
    var bleHandler: BLEHandler?
    
    init() {
        bleHandler = BLEHandler()
        manager = CBCentralManager(delegate: self.bleHandler, queue: nil)
    }
}

class BLEHandler: NSObject, CBCentralManagerDelegate {
    
    override init() {
        super.init()
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Called")
        switch central.state {
        case .unsupported:
            print("BLE is not supported")
        case .unauthorized:
            print("BLE is unauthorized")
        case .unknown:
            print("BLE is unknow")
        case .resetting:
            print("BLE is resetting")
        case .poweredOn:
            print("BLE is on")
            print("Start scanning...")
            central.scanForPeripherals(withServices: nil, options: nil)
        case .poweredOff:
            print("BLE is off")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("\(peripheral.name ?? "default name")");
    }
}
