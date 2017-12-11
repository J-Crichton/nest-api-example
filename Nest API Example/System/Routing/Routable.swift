//
//  Routable.swift
//  Nest API Example
//
//  Created by Eugene on 11/12/2017.
//  Copyright © 2017 Eugene Martinson. All rights reserved.
//

import Foundation
import ObjectiveC

public protocol Router {
    func showAuthorization()
    func showAuthorizedMain()
}

public protocol Routable {
    var router: Router {get}
}

extension Routable {
    var router: Router {
        get {
            return UniversalRouter.shared
        }
    }
}

// MARK: - ObjC Associated Objects

private var associationKey : UInt8 = 0

public func associatedObject<ValueType: AnyObject>(_ base: AnyObject, key: UnsafePointer<UInt8>, initialiser: () -> ValueType) -> ValueType {
    if let associated = objc_getAssociatedObject(base, key)
        as? ValueType {
        return associated
    }
    let associated = initialiser()
    objc_setAssociatedObject(base, key, associated, .OBJC_ASSOCIATION_RETAIN)
    return associated
}

public func associateObject<ValueType: AnyObject>(_ base: AnyObject, key: UnsafePointer<UInt8>, value: ValueType) {
    objc_setAssociatedObject(base, key, value, .OBJC_ASSOCIATION_RETAIN)
}
