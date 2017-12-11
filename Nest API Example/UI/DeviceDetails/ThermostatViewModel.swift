//
//  ThermostatViewModel.swift
//  Nest API Example
//
//  Created by Eugene on 11/12/2017.
//  Copyright © 2017 Eugene Martinson. All rights reserved.
//

import Foundation
import RxSwift

class ThermostatViewModel: Routable {
    
    var device: Variable<NestThermostat>
    
    init(_ device: NestThermostat) {
        self.device = Variable(device)
    }
    
    var increment_step: Float {
        get {
            if device.value.temperature_scale.lowercased() == "c" {
                return 0.5
            }
            return 1
        }
    }
    
    func changeTemperature(_ value: Float) {
        print("New Temperature: \(value)")
        let step  = increment_step
        let roundedValue = round(value / step) * step
        
        SystemContext.shared.nestAPI.setTargetTemperature(roundedValue, for: device.value) { (error) in
            if error == nil {
                self.device.value.target_temperature = roundedValue
            }
        }
    }
    
}
