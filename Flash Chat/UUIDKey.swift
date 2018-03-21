//
//  UUIDKey.swift
//  Basic Chat
//
//  Created by Trevor Beaton on 12/3/16.
//  Copyright © 2016 Vanguard Logic LLC. All rights reserved.
//

import CoreBluetooth
//Uart Service uuid


let kBLEService_UUID = "BF56594D-2D2E-36F2-AC8B-31B2856F8462"
let kBLE_Characteristic_uuid_Tx = "BF56594D-2D2E-36F2-AC8B-31B2856F8462"
let kBLE_Characteristic_uuid_Rx = "BF56594D-2D2E-36F2-AC8B-31B2856F8462"
//let kBLE_Characteristic_uuid_Tx = "FFE0"
//let kBLE_Characteristic_uuid_Rx = "FFE0"
let MaxCharacters = 20

let BLEService_UUID = CBUUID(string: kBLEService_UUID)
let BLE_Characteristic_uuid_Tx = CBUUID(string: kBLE_Characteristic_uuid_Tx)//(Property = Write without response)
let BLE_Characteristic_uuid_Rx = CBUUID(string: kBLE_Characteristic_uuid_Rx)// (Property = Read/Notify)

