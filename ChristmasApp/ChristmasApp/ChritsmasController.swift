//
//  ViewController.swift
//  MyBluetooth
//
//  Created by Norbert Danneberg on 15.12.19.
//  Copyright © 2019 eCloud Technologies. All rights reserved.
//

import UIKit
import CoreBluetooth
import Combine


class ChristmasController:  NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, ObservableObject{
   
    // @Published var didChange = false
    
    // STEP 0.2: create instance variables of the
      // CBCentralManager and CBPeripheral so they
      // persist for the duration of the app's life
    var centralManager: CBCentralManager?
    var peripheralCribController: CBPeripheral?
    var txCharacteristic : CBCharacteristic?
    var rxCharacteristic : CBCharacteristic?
    @Published var btManagerStatus = String("Unknown")
    @Published var btIsConnected: Bool = false
 
    let cribUUID = UUID(uuidString: "08EA052C-6568-26A0-B6CB-CA833823801B")
    let cribUartServiceUUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    let cribBLECharateristicsRX = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
    let cribBLECharateristicsTX = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
    let onCommand = "Ein"
    let offCommand = "Aus"
    let dimCommand = "Dim"
    let annimateCommand = "Annimation"
    var led : LEDData
    let encoder = JSONEncoder()
    
    //@IBOutlet weak var bluetoothOffLabel: UILabel!
    var status = String()
    //@IBOutlet weak var connectingActivityIndicator: UIActivityIndicatorView!
    
    
    override init() {
        
        //led = LEDData (brightness: 0, red: 0, green: 0, blue: 0  )
        led = LEDData (br: 0 , r:233 , g:12, b:150)

        super.init()
        // Do any additional setup after loading the view.
        status = "Ein"
       
        
        // btStatus = "disconnected"
        //bluetoothOffLabel.alpha = 0.0
        // STEP 1: create a concurrent background queue for the central
        // let centralQueue: DispatchQueue = DispatchQueue(label: "com.iosbrain.centralQueueName", attributes: .concurrent)
        // STEP 2: create a central to scan for, connect to,
        // manage, and collect data from peripherals
        print("Init")
        centralManager = CBCentralManager(delegate: self, queue: nil)

    }
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
        
        case .unknown:
            print("Bluetooth status is UNKNOWN")
            btManagerStatus = "Unknown"
            // bluetoothOffLabel.alpha = 1.0
        case .resetting:
            print("Bluetooth status is RESETTING")
            btManagerStatus = "Resetting"
            // bluetoothOffLabel.alpha = 1.0
        case .unsupported:
            print("Bluetooth status is UNSUPPORTED")
            btManagerStatus = "Unsupported"
            // bluetoothOffLabel.alpha = 1.0
        case .unauthorized:
            print("Bluetooth status is UNAUTHORIZED")
            btManagerStatus = "Unauthorized"
           // bluetoothOffLabel.alpha = 1.0
        case .poweredOff:
            print("Bluetooth status is POWERED OFF")
            btManagerStatus = "Powered Off"
            // bluetoothOffLabel.alpha = 1.0
        case .poweredOn:
            btManagerStatus = "Powered On"
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
            btManagerStatus = "Error in BT MAnager"
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
        btIsConnected = true
        peripheral.discoverServices(nil)
       
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnetced to cribController")
        print(error as Any)
        btIsConnected = false
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
    
    func reconnect()  {
        if (centralManager!.isScanning){
            centralManager?.stopScan()
        }
        centralManager?.connect(peripheralCribController!)
    
    }
    
    func changeLightStatus(IsOn: Bool) {
        
        var didChange: Bool
        
        if (IsOn) {
            led.br = 255
            status  = "Ein"
            didChange = sendCommandtoCrib(led: led, ledNumber: 0)
        }
        else
        {
            led.br = 0
            status = "Aus"
            didChange = sendCommandtoCrib(led: led, ledNumber :0)
        }
        
    }
    
    func changeLightBrighness(brightness: Float){
        led.br = UInt8(brightness)
        sendCommandtoCrib(led: led, ledNumber: 0)
    }
    
    func changeLightColor(color: UIColor){
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        led.r = UInt8(red*255)
        led.g = UInt8(green*255)
        led.b = UInt8(blue*255)
        
        sendCommandtoCrib(led: led, ledNumber: 0)
        print("Changing Color red: \(led.r) green \(led.g) blue \(led.b)")
    }
    
    func sendCommandtoCrib(led: LEDData, ledNumber: integer_t) -> Bool{
       
        var thisCommand = ""        
        let maxPacketSize = peripheralCribController?.maximumWriteValueLength(for: .withoutResponse) ?? 2
              // print (maxPacketSize)
        
        do {
                thisCommand = try String(data: encoder.encode(led), encoding: .utf8)!
            // message = String(data: data!, encoding: .utf8)!
        }
        catch {
            print("unexpeced erroe encoding JSON")
        }
        // let valueString = String(data: data, encoding: .utf8)
        //let valueString = (thisCommand as NSString).data(using: String.Encoding.utf8.rawValue)
        
        // let package : Data = testCommand.data(using: String.Encoding.utf8)!
        let packageLength: Int = thisCommand.lengthOfBytes(using: String.Encoding.utf8)
        // let startIndex = 0
        let packageSize: Int  = maxPacketSize - 1
        
        let numberofSubPackages: Int = packageLength / packageSize
        
        var partMessages: [String] = []
        

        // Decompose the message into subpackages that are small enough to send
        
        for i in 0..<numberofSubPackages {
            
            let startIndex = thisCommand.index(thisCommand.startIndex, offsetBy: i*packageSize)
            let endIndex = thisCommand.index(thisCommand.startIndex, offsetBy: i*packageSize+packageSize)
            partMessages.append(String(thisCommand[startIndex..<endIndex]))
            //print(subStrings[i])
        }
        
        let startIndex = thisCommand.index(thisCommand.startIndex, offsetBy: numberofSubPackages*packageSize)
        
        if (numberofSubPackages*packageSize < packageLength){
            partMessages.append(String(thisCommand[startIndex..<thisCommand.endIndex]))
            
            // print(subStrings[numberofSubPackages])
        }
        
        for partMessage in partMessages {
        peripheralCribController?.writeValue(partMessage.data(using: String.Encoding.utf8)!, for: txCharacteristic! , type: CBCharacteristicWriteType.withoutResponse)
        // print(testCommand)
        }
        return true
    }

}

