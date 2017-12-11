//
//  Models.swift
//  Nest API Example
//
//  Created by Eugene on 11/12/2017.
//  Copyright © 2017 Eugene Martinson. All rights reserved.
//

import Foundation

struct NestDevices: Codable {
    var thermostats: [NestThermostat] = []
}

public struct NestThermostat: Codable {
    var device_id: String
    var name: String
    var target_temperature_c: Float
    var target_temperature_f: Float
    
    var target_temperature_high_c: Float
    var target_temperature_high_f: Float
    var target_temperature_low_c: Float
    var target_temperature_low_f: Float
    
    var temperature_scale: String
    var locale: String
}

extension NestThermostat {
    var target_temperature_bounds: (Float, Float) {
        if temperature_scale.lowercased() == "c" {
            return (target_temperature_low_c, target_temperature_high_c)
        }
        return (target_temperature_low_f, target_temperature_high_f)
    }
    
    var target_temperature: Float {
        get {
            if temperature_scale.lowercased() == "c" {
                return target_temperature_c
            }
            return target_temperature_f
        }
        set {
            if temperature_scale.lowercased() == "c" {
                target_temperature_c = newValue
            }
            target_temperature_f = newValue
        }
    }
    
    var target_temperature_description: String {
        return "\(target_temperature) °\(temperature_scale)"
    }
}
