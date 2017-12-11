//
//  NestAPI.swift
//  Nest API Example
//
//  Created by Eugene on 11/12/2017.
//  Copyright © 2017 Eugene Martinson. All rights reserved.
//

import Foundation

public typealias DevicesCompletion<Device> = ([Device], Error?) -> ()

public protocol NestAPI {
    var authorizationStatus: AuthorizationStatus  {get}
    func authorize(_ code: String, _ completion: @escaping CompletionHandler)
    func getThermostats(_ completion: @escaping DevicesCompletion<NestThermostat>)
    func setTargetTemperature(_ value: Float, for thermostat: NestThermostat, _ completion: @escaping CompletionHandler)
}

public class RESTNestAPI: NestAPI {
    
    let restClient: RestClient
    
    public var authorizationStatus: AuthorizationStatus {
        return restClient.authorizationStatus
    }
    
    public init(_ onAuthorizationStatusChange: @escaping ((AuthorizationStatus) -> ())) {
        restClient = RestClient(tokenPersister: DefaultTokenPersister(), baseURL: NestConstants.baseURL, onAuthorizationStatusChange)
    }
    
    public func authorize(_ code: String, _ completion: @escaping CompletionHandler) {
        let request = PINAuthRequest(with: NestConstants.clientID, secret: NestConstants.secret, pin: code)
        
        restClient.sendRequest(request) { (response, context) in
            completion(context?.error as NSError?)
        }
    }
    
    public func getThermostats(_ completion: @escaping DevicesCompletion<NestThermostat>) {
        
        guard let token = restClient.tokenPersister.getToken() else {
            completion([], NSError(domain: "Unauthorized", code: 401, userInfo: nil))
            return
        }
        
        let request = DevicesRequest(token.access_token)
        
        restClient.sendRequest(request) { (response, context) in
            
            completion(response.value?.thermostats ?? [], response.error)
        }
    }
    
    public func setTargetTemperature(_ value: Float, for thermostat: NestThermostat, _ completion: @escaping CompletionHandler) {
        
        guard let token = restClient.tokenPersister.getToken() else {
            completion(NSError(domain: "Unauthorized", code: 401, userInfo: nil))
            return
        }
        
        var key = "target_temperature_f"
        
        if thermostat.temperature_scale.lowercased() == "c" {
            key = "target_temperature_c"
        }
        
        let changes: [String : Any] = [key: value]
        
        let request = PutThermostatRequest(changes: changes, device: thermostat.device_id, token.access_token)
        
        restClient.sendRequest(request) { (response, context) in
            
            completion(response.error as NSError?)
        }
    }
}
