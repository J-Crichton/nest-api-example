//
//  ViewStateLoadable.swift
//  Nest API Example
//
//  Created by Eugene on 11/12/2017.
//  Copyright © 2017 Eugene Martinson. All rights reserved.
//

import Foundation
import RxSwift

enum ViewLoadingState {
    case loading
    case success
    case failed(Error)
}

protocol ViewStateLoadable {
    var state: Variable<ViewLoadingState> { get set }
    
    func loadData()
}
