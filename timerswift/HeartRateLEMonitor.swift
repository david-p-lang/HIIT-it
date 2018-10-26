//
//  HeartRateLEMonitor.swift
//  Vis2
//
//  Created by David Lang on 3/8/15.
//  Copyright (c) 2015 David Lang. All rights reserved.
//

import Foundation
import CoreBluetooth


class HeartRateLEMonitor:NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    
    var centralManager:CBCentralManager!
    var thePeripheral: CBPeripheral!
    var heartRateCharacteristic: CBCharacteristic!
    var currentHeartRate = 0
    var blueToothReady = false
    var bluetoothConnected = false
    
    var InfoService:CBUUID = CBUUID(string: "180A")
    var HeartRateService:CBUUID = CBUUID(string: "180D")
    var HeartRateCharUUID:CBUUID = CBUUID(string: "2A37")
    var HeartRateLocation:CBUUID = CBUUID(string: "2A38")
    var HRManu:CBUUID = CBUUID(string: "2A29")
    var batteryLevelCharUUID:CBUUID = CBUUID(string: "2A19")
    var serialNumberUUID:CBUUID = CBUUID(string: "2A25")
    
    var heartRateCBServiceCollection:[AnyObject] = [CBUUID(string: "180D")]
    var heartRateCBService:CBService!
    var periphs:[AnyObject]!
    var knownMonitors = ""
    
    var heartRateCheckerCount = 0
    var heartRateCheckerNew = ""
    var heartRateCheckerOld = ""
    
    
    var notification = NotificationCenter.default
    
    //===============================CUSTOM FUNCTIONS==============================
    func startUpCentralManager() {
        NSLog("Initializing central manager")
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    //===============================DISCOVER DEVICES==============================
    func discoverDevices() {
        NSLog("discovering devices")
        if bluetoothConnected == false {
            self.periphs = centralManager.retrieveConnectedPeripherals(withServices: [self.HeartRateService])
            print("system connected peripherals: \(periphs.count)")
            if periphs.count > 0 {
                for i in 0...periphs.count - 1 {
                    //notification.postNotificationName("devices", object: nil, userInfo: ["theDevices":"checkPeriphs"])
                    notification.post(name: NSNotification.Name(rawValue: "devices"), object: nil, userInfo: ["theDevices":"checkPeriphs"])
                    let v: AnyObject  = periphs[i]
                    var idChecker:NSUUID!
                    idChecker = v.identifier as NSUUID
                    if idChecker != nil {
                        //print("* ID: \(idChecker)")
                        //print("* ID: \(v.identifier as NSUUID)")
                        //theMonitorManager.saveMonitor(v.name, andIdentifier: idChecker)
                    }
                }
            }
        }
        if self.periphs.count == 0 {
            print("Still scanning for a device")
            centralManager.scanForPeripherals(withServices: [HeartRateService], options: nil)
        }
        
    }
    //==============================STOP SCANNING============================
    func stopScanning() {
        centralManager.stopScan()
    }
    //=============================USER SCAN FOR PERIPHERAL========================
    func scanForMonitor() {
        centralManager.scanForPeripherals(withServices: [HeartRateService], options: nil)
    }
    //=============================CHECK HEART RATE CONNECTION=====================
    func checkHeartRateConnection() {
        switch self.thePeripheral.state {
        case .disconnected:
            bluetoothConnected = false
        default:
            bluetoothConnected = false
            
        }
    }
    
    //===========================CENTRAL MANAGER FUNCTIONS=========================
    func centralManagerDidUpdateState(_ central: CBCentralManager!) {
        NSLog("checking state")
        var theLEState = ""
        switch (central.state) {
        case .poweredOff:
            theLEState = "Bluetooth is powered off"
        case .poweredOn:
            theLEState = "Bluetooth is ready"
            blueToothReady = true;
        case .resetting:
            theLEState = "Bluetooth on your device is resetting"
        case .unauthorized:
            theLEState = "Bluetooth on your device is unauthorized"
        case .unknown:
            theLEState = "Bluetooth on your device is unknown"
        case .unsupported:
            theLEState = "Bluetooth type needed is unsupported on this platform"
        }
        NSLog(theLEState)
        notification.post(name: NSNotification.Name(rawValue: "bluetoothStatus"), object: nil, userInfo: ["theBTState":theLEState])
        if blueToothReady {
            discoverDevices()
        }
        
    }
    
    func centralManager(central: CBCentralManager!, didRetrievePeripherals peripherals: [AnyObject]!) {
        print("--didretrieveIdentifiedPeripheral")
    }
    func centralManager(central: CBCentralManager!, didRetrieveConnectedPeripherals peripherals: [AnyObject]!) {
        print("--didretrieveConnectedPeripheral")
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        NSLog("--didconnectperipheral")
        peripheral.delegate = self
        switch (peripheral.state) {
        case .connected:
            NSLog("the central manager reports the peripheral state is connected")
            notification.post(name: NSNotification.Name(rawValue: "peripheralStatus"), object: nil, userInfo: ["thePeripheralState":"Connected"])
            self.thePeripheral = peripheral
            self.thePeripheral.discoverServices(nil)
            centralManager.stopScan()
            bluetoothConnected = true
        case .disconnected:
            bluetoothConnected = false
            NSLog("peripheral state is disconnected")
        case .connecting:
            NSLog("peripheral state is connecting")
        case .disconnecting:
            NSLog("peripheral state is connecting")

        }
        
    }
    private func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        NSLog("did fail connect")
    }
    
    @nonobjc func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        NSLog("Discovered \(String(describing: peripheral.name))")
        thePeripheral = peripheral
        notification.post(name: NSNotification.Name(rawValue: "peripheralStatus"), object: nil, userInfo: ["thePeripheralState":"DidDiscover"])
        centralManager.connect(peripheral, options: nil)
        _ = "Disconnected"
        switch (peripheral.state) {
        case .connected:
            NSLog("peripheral state is connected")
            notification.post(name: NSNotification.Name(rawValue: "peripheralStatus"), object: nil, userInfo: ["thePeripheralState":"Connected"])
            bluetoothConnected = true
            centralManager.stopScan()
            return
        case .disconnected:
            NSLog("peripheral state is disconnected")
            bluetoothConnected = false
        case .connecting:
            NSLog("peripheral state is connecting")
        default:
            print(peripheral.state)
            
        }
        
    }
    //==============================PERIPHERAL FUNCTIONS==================================
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        NSLog("did discover services")
        heartRateCBServiceCollection = peripheral.services!
        for heartRateCBService in heartRateCBServiceCollection {
            NSLog("Discovered service: \(heartRateCBService.uuid)")
            if (String(describing: heartRateCBService.uuid) == "Heart Rate") {
                
            }
            self.thePeripheral.discoverCharacteristics(nil, for: heartRateCBService as! CBService)
        }
        
        
    }
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        NSLog("did discover characteristics")
        for chars in service.characteristics! {
            thePeripheral.setNotifyValue(true, for: chars as! CBCharacteristic)
            heartRateCharacteristic = chars as! CBCharacteristic
            thePeripheral.readValue(for: heartRateCharacteristic)
            self.thePeripheral.setNotifyValue(true, for: heartRateCharacteristic)
        }
        
    }
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!,
        error: NSError!)
    {
        if characteristic.uuid == HeartRateCharUUID {
            
            guard let characteristicData = characteristic.value else { return }
            let byteArray = [UInt8](characteristicData)
            var bpm = 0
            let firstBitValue = byteArray[0] & 0x01
            if firstBitValue == 0 {
                bpm = Int(byteArray[1])
            } else {
                bpm = (Int(byteArray[1]) << 8) + Int(byteArray[2])
            }
            
            
            let outputBPM = String(bpm)
            print("-->"+outputBPM)
            
            
            /*switch (reportData[0] & 0x00001) {
            case 0:
            print("Energy Expended field is not present")
            case 1:
            print("Energy Expended field is present. Units: kilo Joules")
            default:
            print("ERROR")
            }
            switch (reportData[0] & 0x000001) {
            case 0:
            print("RR-Interval values are not present")
            case 1:
            print("One or more RR-Interval values are present. Units: 1/1024 seconds")
            default:
            print("ERROR")
            }*/
            
            notification.post(name: NSNotification.Name(rawValue: "heartRateBroadcast"), object: nil, userInfo: ["message":outputBPM])

            
        }
        
    }
}
