//
//  NestDevicesRequest.swift
//  Nest API Example
//
//  Created by Eugene on 11/12/2017.
//  Copyright © 2017 Eugene Martinson. All rights reserved.
//

import Foundation
import Flamingo

struct DevicesRequest: NetworkRequest, AuthorizedRequest {
    
    let code: String
    
    init(_ code: String) {
        self.code = code
    }
    
    //MARK: - Implementation
    
    var URL: URLConvertible {
        return "https://developer-api.nest.com/devices?auth=\(code)"
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var baseURL: URLConvertible? {
        return nil
    }
    
    var parametersEncoder: ParametersEncoder {
        return JSONParametersEncoder()
    }
    
    var headers: [String: String?]? {
        return ["Content-Type":"application/json",
                "Cache-Control":"no-cache"]
    }
    
    var responseSerializer: NestDevicesSerializer<NestDevices> {
        return NestDevicesSerializer<NestDevices>()
    }
}

public struct NestDevicesSerializer<Serialized: Decodable>: ResponseSerialization {
    
    let decoder: JSONDecoder
    
    public init(decoder: JSONDecoder) {
        self.decoder = decoder
    }
    
    public init(dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .base64, nonConformingFloatDecodingStrategy: JSONDecoder.NonConformingFloatDecodingStrategy = .throw) {
        self.init(decoder: JSONDecoder())
        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.dataDecodingStrategy = dataDecodingStrategy
        decoder.nonConformingFloatDecodingStrategy = nonConformingFloatDecodingStrategy
    }
    
    public func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Swift.Error?) -> Result<Serialized> {
        
        guard let data = data else {
            return .error(error ?? Error.unableToRetrieveDataAndError)
        }
        
        var objects: [NestThermostat] = []
        
        do {
            if let JSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let thermostatDevices = JSON["thermostats"]  as? [String: Any] {
                print("JSON: \(JSON)")
                
                for key in thermostatDevices.keys {
                    let item = thermostatDevices[key] as Any
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: item, options: .prettyPrinted)
                        let serialized = try decoder.decode(NestThermostat.self, from: jsonData)
                        objects.append(serialized)
                    } catch {
                        return .error(error)
                    }
                }
            }
        } catch {
            return .error(error)
        }
        
        var nest = NestDevices()
        nest.thermostats = objects
        
        return Result.success(nest) as! Result<Serialized>
    }
    
}
