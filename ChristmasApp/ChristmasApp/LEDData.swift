//
//  LEDData.swift
//  ChristmasApp
//
//  Created by Norbert Danneberg on 06.05.20.
//  Copyright © 2020 eCloud Technologies. All rights reserved.
//

import Foundation

struct LEDData: Codable {
    var br : UInt8 = 0 // brightness
    var r: UInt8 = 128  // red
    var g: UInt8 = 200  // green
    var b: UInt8 = 32  // blue

}
