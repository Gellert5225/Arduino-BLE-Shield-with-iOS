//
//  ViewController.swift
//  Bluetooth
//
//  Created by Jiahe Li on 27/10/2017.
//  Copyright © 2017 Gellert. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    var centralManager: CBCentralManager?
    var peripheral:CBPeripheral!
    var writableCharacteristic: CBCharacteristic?
    var targetService: CBService?
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var UUIDLabel: UILabel!
    @IBOutlet weak var statudLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }
    
    @IBAction func rotate(_ sender: UIButton) {
        let msg = "9"
        let data = msg.data(using: String.Encoding.ascii)//Data(bytes: msg, count: msg.count)
        self.peripheral.writeValue(data!, for: writableCharacteristic!, type: .withoutResponse)
    }
    
    @IBAction func turnOn(_ sender: UIButton) {
        let msg = "ON"
        let data = msg.data(using: String.Encoding.ascii)//Data(bytes: msg, count: msg.count)
        self.peripheral.writeValue(data!, for: writableCharacteristic!, type: .withoutResponse)
    }
    
    @IBAction func turnOff(_ sender: UIButton) {
        let msg = "OFF"
        let data = msg.data(using: String.Encoding.ascii)//Data(bytes: msg, count: msg.count)
        self.peripheral.writeValue(data!, for: writableCharacteristic!, type: .withoutResponse)
    }
}

extension ViewController: CBCentralManagerDelegate, CBPeripheralDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if (central.state == .poweredOn){
            self.centralManager?.scanForPeripherals(withServices: nil, options: nil)
        }
        else {
            // do something like alert the user that ble is not on
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        statudLabel.text = "Status: Connected"
        peripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }
        
        targetService = services.first
        if let service = services.first {
            targetService = service
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else { return }
        
        let value = data.withUnsafeBytes { (ptr: UnsafePointer<Int>) -> Int in
            return ptr.pointee
        }
        
        distanceLabel.text = "Distance: \(String(value)) cm"
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        for characteristic in characteristics {
            if characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse) {
                print(characteristic)
                UUIDLabel.text = "UUID: \(characteristic.uuid)"
                writableCharacteristic = characteristic
            }
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.isNotifying {
            print("Notification begin on \(characteristic)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let device = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey)
            as? NSString

        if device?.contains("TEST") == true {
            self.centralManager?.stopScan()
            
            self.peripheral = peripheral
            self.peripheral.delegate = self
            
            centralManager?.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        statudLabel.text = "Status: Disconnected"
        self.centralManager?.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        let alert = UIAlertController(title: "Alert", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        self.centralManager?.scanForPeripherals(withServices: nil, options: nil)
    }
}

