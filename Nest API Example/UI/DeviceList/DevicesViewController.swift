//
//  DevicesViewController.swift
//  Nest API Example
//
//  Created by Eugene on 11/12/2017.
//  Copyright © 2017 Eugene Martinson. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class DevicesViewController: UITableViewController {
    
    let model = DevicesViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = nil
        tableView.dataSource = nil
        
        _ = model.state.asObservable().subscribe(onNext: {
            state in
            switch state {
            case .loading: self.title = "Loading"
            default:
                self.title = "Devices"
            }
        })
        
        model.devices.asObservable().bind(to: tableView.rx
            .items(cellIdentifier: "DeviceCell")) { index, model, cell in
                
                cell.textLabel?.text = model.name
                cell.detailTextLabel?.text = model.target_temperature_description
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.performSegue(withIdentifier: "ShowDetails", sender: indexPath)
            }).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        model.loadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let indexPath = sender as? IndexPath else {
            return
        }
        
        let destination = segue.destination as! ThermostatViewController
        
        destination.model = model.viewModelForDevice(at: indexPath.row)
    }
}
