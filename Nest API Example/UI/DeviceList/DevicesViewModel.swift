//
//  DevicesViewModel.swift
//  Nest API Example
//
//  Created by Eugene on 11/12/2017.
//  Copyright © 2017 Eugene Martinson. All rights reserved.
//

import Foundation
import RxSwift

class DevicesViewModel: ViewStateLoadable {
    
    var state: Variable<ViewLoadingState> = Variable(.loading)
    
    var devices: Variable<[NestThermostat]> = Variable([])
    
    func viewModelForDevice(at index: Int) -> ThermostatViewModel {
        assert(index < devices.value.count)
        return ThermostatViewModel(devices.value[index])
    }
    
    func loadData() {
        state.value = ViewLoadingState.loading
        SystemContext.shared.nestAPI.getThermostats { [weak self] (thermostats, error) in
            if let error = error {
                self?.state.value = ViewLoadingState.failed(error)
            } else {
                self?.devices.value = thermostats
                self?.state.value = ViewLoadingState.success
            }
        }
    }
}
