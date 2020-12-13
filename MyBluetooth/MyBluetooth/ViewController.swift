//
//  ViewController.swift
//  MyBluetooth
//
//  Created by Norbert Danneberg on 15.12.19.
//  Copyright © 2019 eCloud Technologies. All rights reserved.
//

import UIKit
import CoreBluetooth
   
class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate{
   
    // STEP 0.2: create instance variables of the
      // CBCentralManager and CBPeripheral so they
      // persist for the duration of the app's life
    var centralManager: CBCentralManager?
    var peripheralCribController: CBPeripheral?
    var txCharacteristic : CBCharacteristic?
    var rxCharacteristic : CBCharacteristic?
 
    let cribUUID = UUID(uuidString: "08EA052C-6568-26A0-B6CB-CA833823801B")
    let cribUartServiceUUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    let cribBLECharateristicsRX = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
    let cribBLECharateristicsTX = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
    let onCommand = "Ein"
    let offCommand = "Aus"
    let dimCommand = "Dim"
    let annimateCommand = "Annimation"
    
    
    //@IBOutlet weak var bluetoothOffLabel: UILabel!
    @IBOutlet weak var status: UILabel!
    //@IBOutlet weak var connectingActivityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        status.text = "Ein"
        //bluetoothOffLabel.alpha = 0.0
        // STEP 1: create a concurrent background queue for the central
        // let centralQueue: DispatchQueue = DispatchQueue(label: "com.iosbrain.centralQueueName", attributes: .concurrent)
        // STEP 2: create a central to scan for, connect to,
        // manage, and collect data from peripherals
        centralManager = CBCentralManager(delegate: self, queue: nil)

    }
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
        
        case .unknown:
            print("Bluetooth status is UNKNOWN")
            // bluetoothOffLabel.alpha = 1.0
        case .resetting:
            print("Bluetooth status is RESETTING")
            // bluetoothOffLabel.alpha = 1.0
        case .unsupported:
            print("Bluetooth status is UNSUPPORTED")
            // bluetoothOffLabel.alpha = 1.0
        case .unauthorized:
            print("Bluetooth status is UNAUTHORIZED")
           // bluetoothOffLabel.alpha = 1.0
        case .poweredOff:
            print("Bluetooth status is POWERED OFF")
            // bluetoothOffLabel.alpha = 1.0
        case .poweredOn:
            print("Bluetooth status is POWERED ON")
           
            /*
            DispatchQueue.main.async { () -> Void in
                //self.bluetoothOffLabel.alpha = 0.0
                // self.connectingActivityIndicator.startAnimating()
            }
            */
            
            // STEP 3.2: scan for peripherals that we're interested in
            centralManager?.scanForPeripherals(withServices: [cribUartServiceUUID])
            
            
        @unknown default:
            print("Error in Central Manager")
        } // END switch
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // UUID of my personal Adafruit Feather MO
        if peripheral.identifier == cribUUID {
            print(peripheral)
            peripheralCribController = peripheral
            centralManager?.stopScan()
            centralManager?.connect(peripheralCribController!)
            peripheralCribController?.delegate = self
            
        }

    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Successful connetced to cribController")
        peripheral.discoverServices(nil)
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {return}
        
        for service in services {
            print(service)
            // print(service.uuid)
           peripheral.discoverCharacteristics(nil, for: service)
        }
    }
 
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        if service.uuid == cribUartServiceUUID {
            for characteristic in characteristics {
                print(characteristic)
                if (characteristic.uuid == cribBLECharateristicsRX ) {
                    rxCharacteristic = characteristic
                }
                
                if (characteristic.uuid == cribBLECharateristicsTX ) {
                    txCharacteristic = characteristic
                }
            }
            
        }
    }
    
    @IBAction func einButton(_ sender: UIButton) {
        status.text = "Ein"
        sendCommandtoCrib(command: "Ein", ledNumber: 0)
        
    }
    
    @IBAction func ausButton(_ sender: UIButton) {
        status.text = "Aus"
        sendCommandtoCrib(command: "Aus", ledNumber: 0)

    }
    
    func sendCommandtoCrib(command: String, ledNumber: integer_t) -> Bool{
       
        var thisCommand = command
        thisCommand.append("  \(ledNumber)")
        
        let valueString = (thisCommand as NSString).data(using: String.Encoding.utf8.rawValue)
        
        peripheralCribController?.writeValue(valueString!, for: txCharacteristic! , type: CBCharacteristicWriteType.withoutResponse)

        return true
    }

}

