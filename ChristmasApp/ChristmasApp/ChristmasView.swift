//
//  ContentView.swift
//  ChristmasApp
//
//  Created by Norbert Danneberg on 03.05.20.
//  Copyright © 2020 eCloud Technologies. All rights reserved.
//

import SwiftUI
import ColorPicker

struct BluetoothConnectButton: View {
    @Binding var btTryToConnect: Bool
    // @Binding var btIsConnected: Bool
    @ObservedObject var christmasController : ChristmasController
    var body: some View {
        VStack {
            Button(action: {
                self.btTryToConnect.toggle()
                self.christmasController.reconnect()
            })
            {
                Image(systemName: "dot.radiowaves.left.and.right")
                    //Image("bluetooth_symbol_small")
                    .resizable()
                    .frame(width: 34, height: 24, alignment: .bottom)
                    .foregroundColor(self.christmasController.btIsConnected ? .blue : .gray)
            }
        }
    }
}

struct ChristmasView: View {
    
    @State private var btTryToConnect: Bool = false
    //@State private var btIsConnected: Bool = false
    @State private var lightIsOn: Bool = false
    @State private var ledColor: UIColor = UIColor.red
    
    @State private var brightnessSliderPosition: Float = 125
    @ObservedObject var christmastController = ChristmasController()
    private var btTest: Bool = false
    // btTest =  christmastController.btIsConnected
    let isConnectedMsg =  "Bluetooth connected"
    let isDisconnectdMsg = "No Blutooth connection"
    var body: some View {
        
        VStack{
            HStack{
                
                BluetoothConnectButton(btTryToConnect: $btTryToConnect,
                                       christmasController: self.christmastController)
                
                Text((christmastController.btIsConnected ? isConnectedMsg : isDisconnectdMsg))
                
            }
            
            ZStack {
                ColorPicker(color: Binding(
                    get: {
                        self.ledColor
                },
                    set: {(newColor) in
                        self.ledColor = newColor
                        self.christmastController.changeLightColor(color: self.ledColor)
                }
                    ),
                            strokeWidth: 30)
                    
                    .frame(width: 200, height: 200, alignment: .center)
                    .onTapGesture {self.christmastController.changeLightBrighness(brightness: self.brightnessSliderPosition)
                }
                
                OnOffButton(isOn: $lightIsOn,
                            // btIsConnected : $btIsConnected,
                    christmasController: self.christmastController)
                
            }
            Slider(value: Binding(
                get: {return self.brightnessSliderPosition},
                set: {
                    (newBrightness) in self.brightnessSliderPosition = newBrightness
                    self.christmastController.changeLightBrighness(brightness: newBrightness)
            }
                ),
                
                   in: 0...255,
                   onEditingChanged: {_ in self.christmastController.changeLightBrighness(brightness: self.brightnessSliderPosition)})
                .padding()
            
            
            //Text(self.christmastController.btManagerStatus)
            //Text(self.christmastController.btIsConnected.description)
        }
        
    }
}

struct OnOffButton : View{
    
    @Binding var isOn : Bool
    // @Binding var btIsConnected: Bool
    @ObservedObject var christmasController : ChristmasController
    
    var body: some View {
        Button(action: {
            self.isOn.toggle()
            self.christmasController.changeLightStatus(IsOn: self.isOn)
            print("OnOffButton")
            print(self.isOn.description)
        }){
            Image(systemName: (isOn && self.christmasController.btIsConnected) ? "play.circle" : "pause.circle")
                .padding(.top)
                .padding(.bottom)
                .font(.system(size: 56.0))
                //.foregroundColor(Color.white)
                .foregroundColor((isOn && self.christmasController.btIsConnected) ? Color.blue : Color.gray)
        }
        //.frame(width: 50, height: 50)
        //.shadow(radius: 40)
        //.cornerRadius(10)
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ChristmasView()
    }
}
