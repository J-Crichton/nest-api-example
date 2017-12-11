//
//  DeviceDetails.swift
//  Nest API Example
//
//  Created by Eugene on 11/12/2017.
//  Copyright © 2017 Eugene Martinson. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ThermostatViewController: UIViewController {
    
    var model: ThermostatViewModel!
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var targetTemp: UILabel!
    @IBOutlet weak var tempSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tempSlider.minimumValue = model.device.value.target_temperature_bounds.0
        tempSlider.maximumValue = model.device.value.target_temperature_bounds.1
        tempSlider.value = model.device.value.target_temperature
        
        model.device.asObservable()
            .map { device -> String? in
                return device.target_temperature_description
            }
            .bind(to: self.targetTemp.rx.text)
            .disposed(by: self.disposeBag)
        
        tempSlider.rx.value
            .throttle(0.3, latest: true, scheduler: MainScheduler.instance)
            .subscribe(onNext: { value in
                self.model.changeTemperature(Float(value))
            })
            .disposed(by: disposeBag)
    }
}
