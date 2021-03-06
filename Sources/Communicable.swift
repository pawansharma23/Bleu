//
//  Communicable.swift
//  Antenna
//
//  Created by 1amageek on 2017/01/25.
//  Copyright © 2017年 Stamp inc. All rights reserved.
//

import Foundation
import CoreBluetooth

public enum RequestMethod {
    case get(Bool)
    case post
    case broadcast(Bool)
    
    var properties: CBCharacteristicProperties {
        switch self {
        case .get(let isNotify):
            if isNotify { return [.read, .notify] }
            return .read
        case .post: return .write
        case .broadcast(let isNotify):
            if isNotify { return [.read, .notify, .broadcast] }
            return [.read, .broadcast]
        }
    }
    
    var permissions: CBAttributePermissions {
        switch self {
        case .get: return .readable
        case .post: return .writeable
        case .broadcast: return .readable
        }
    }
}

public protocol Communicable: Hashable {
    
    var serviceUUID: CBUUID { get }
    
    var method: RequestMethod { get }
    
    var value: Data? { get }
    
    var characteristicUUID: CBUUID? { get }
    
    var characteristic: CBMutableCharacteristic { get }
    
}

extension Communicable {
    
    public var method: RequestMethod {
        return .get(false)
    }
    
    public var value: Data? {
        return nil
    }
    
    public var hashValue: Int {
        guard let characteristicUUID: CBUUID = self.characteristicUUID else {
            fatalError("*** Error: characteristicUUID must be defined for Communicable.")
        }
        return characteristicUUID.hash
    }
    
    public var characteristic: CBMutableCharacteristic {
        return CBMutableCharacteristic(type: self.characteristicUUID!, properties: self.method.properties, value: nil, permissions: self.method.permissions)
    }
    
}

public func == <T: Communicable>(lhs: T, rhs: T) -> Bool {
    return lhs.characteristicUUID == rhs.characteristicUUID
}
