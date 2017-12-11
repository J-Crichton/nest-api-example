//
//  PutDeviceRequest.swift
//  Nest API Example
//
//  Created by Eugene on 11/12/2017.
//  Copyright © 2017 Eugene Martinson. All rights reserved.
//

import Foundation
import Flamingo

struct PutThermostatRequest: NetworkRequest, AuthorizedRequest {
    
    let code: String
    let device: String
    let changes: [String : Any]
    
    init(changes: [String : Any], device id: String, _ code: String) {
        device = id
        self.code = code
        self.changes = changes
    }
    
    //MARK: - Implementation
    
    var URL: URLConvertible {
        return "https://developer-api.nest.com/devices/thermostats/\(device)?auth=\(code)"
    }
    
    var method: HTTPMethod {
        return .put
    }
    
    var parameters: [String: Any]? {
        return changes
    }
    
    var baseURL: URLConvertible? {
        return nil
    }
    
    var parametersEncoder: ParametersEncoder {
        return JSONParametersEncoder()
    }
    
    var headers: [String: String?]? {
        return ["Content-Type":"application/x-www-form-urlencoded",
                "Cache-Control":"no-cache"]
    }
    
    var responseSerializer: NestDevicesSerializer<NestDevices> {
        return NestDevicesSerializer<NestDevices>()
    }
}
