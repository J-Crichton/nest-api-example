//
//  PINAuthRequest.swift
//  Nest API Example
//
//  Created by Eugene on 11/12/2017.
//  Copyright © 2017 Eugene Martinson. All rights reserved.
//

import Foundation
import Flamingo

public struct PINAuthRequest: NetworkRequest, TokenRequest {
    
    let code: String
    let clientID: String
    let secret: String
    
    init(with clientID: String, secret: String, pin code: String) {
        self.clientID = clientID
        self.secret = secret
        self.code = code
    }
    
    //MARK: - Implementation
    
    public var method: HTTPMethod {
        return .post
    }
    
    public var baseURL: URLConvertible? {
        return nil
    }
    
    public var URL: URLConvertible {
        return "https://api.home.nest.com/oauth2/access_token"
    }
    
    public  var parameters: [String: Any]? {
        return ["client_id": clientID,
                "client_secret": secret,
                "grant_type": grantType,
                "code": code]
    }
    
    public var parametersEncoder: ParametersEncoder {
        return URLParametersEncoder()
    }
    
    public var headers: [String: String?]? {
        return ["Content-Type": "application/x-www-form-urlencoded; charset=utf-8"]
    }
    
    public var responseSerializer: CodableJSONSerializer<AccessToken> {
        return CodableJSONSerializer<AccessToken>()
    }
}
