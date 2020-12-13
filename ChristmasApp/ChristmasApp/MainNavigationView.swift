//
//  MainNavigationView.swift
//  ChristmasApp
//
//  Created by Norbert Danneberg on 25.05.20.
//  Copyright © 2020 eCloud Technologies. All rights reserved.
//

import SwiftUI

struct MainNavigationView: View {
    @State private var pushedBlScanButton: Bool = false
    var body: some View {
        HStack{
            Button(action: {self.pushedBlScanButton.toggle()}
                
            ){
                Image("bluetooth_symbol_large")
                    .resizable()
                    .padding(.all)
                    .frame(width: 100, height: 100)
                //.foregroundColor(.green)
            }
            
            Button(action: {self.pushedBlScanButton.toggle()}
                
            ){
                Image("bluetooth_symbol_large")
                    .resizable()
                    .padding(.all)
                    .frame(width: 100, height: 100)
                //.foregroundColor(.green)
            }
        }
    }
}

struct MainNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        MainNavigationView()
    }
}
