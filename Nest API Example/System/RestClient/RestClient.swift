//
//  RestClient.swift
//  Nest API Example
//
//  Created by Eugene on 11/12/2017.
//  Copyright © 2017 Eugene Martinson. All rights reserved.
//

import Foundation
import Flamingo

public struct AccessToken: Codable {
    var access_token: String
    var type: String
    var expires_in: Int
    
    public init(value: String, expires_in: Int, type: String = "Bearer") {
        self.access_token = value
        self.type = type
        self.expires_in = expires_in
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.access_token = try values.decode(String.self, forKey: .access_token)
        self.expires_in = try values.decode(Int.self, forKey: .expires_in)
        
        self.type = try values.decodeIfPresent(String.self, forKey: .type) ?? "Bearer"
    }
}

public typealias CompletionHandler = (NSError?) -> ()

public enum NetworkStatusCodes: Int {
    case serverError      = 400
    case unauthorized     = 401
}

public enum AuthorizationStatus: Int {
    case unauthorized
    case authorized
}

public protocol TokenRequest {
    
    var grantType: String { get }
}

extension TokenRequest {
    public var grantType: String {
        return "authorization_code"
    }
}

public protocol AuthorizedRequest {
    
}

public struct Headers {
    public static let Authorization : String = "Authorization"
}

public class RestClient: NetworkDefaultClient {
    
    public var tokenPersister: TokenPersister
    
    public var authorizationStatus: AuthorizationStatus = .unauthorized {
        didSet {
            onAuthorizationStatusChange?(authorizationStatus)
        }
    }
    
    private var onAuthorizationStatusChange: ((AuthorizationStatus) -> ())?
    
    public init(tokenPersister: TokenPersister,
                baseURL: String, _ onAuthorizationStatusChange: @escaping ((AuthorizationStatus) -> ())) {
        self.tokenPersister = tokenPersister
        self.onAuthorizationStatusChange = onAuthorizationStatusChange
        self.authorizationStatus = tokenPersister.getToken() != nil ? .authorized : .unauthorized
        self.onAuthorizationStatusChange?(authorizationStatus)
        
        let configuration = NetworkDefaultConfiguration(baseURL: baseURL)
        super.init(configuration: configuration, session: URLSession.shared )
    }
    
    override public func customHeadersForRequest<T>(_ networkRequest: T) -> [String : String]? where T : NetworkRequest {
        var headers: [String: String] = [:]
        
        if networkRequest is AuthorizedRequest, let token = tokenPersister.getToken() {
            headers[Headers.Authorization] = "\(token.type) \(token.access_token)"
        }
        
        return headers
    }
    
    @discardableResult
    override public func sendRequest<Request>(_ networkRequest: Request, completionHandler: ((Result<Request.ResponseSerializer.Serialized>, NetworkContext?) -> Void)?) -> CancelableOperation? where Request : NetworkRequest {
        if networkRequest is TokenRequest {
            return super.sendRequest(networkRequest, completionHandler: { (response, context) in
                if let token = response.value as? AccessToken {
                    
                    self.tokenPersister.setToken(token)
                    if self.authorizationStatus != .authorized {
                        self.authorizationStatus = .authorized
                    }
                    completionHandler?(response, context)
                } else {
                    if self.authorizationStatus == .authorized {
                        self.authorizationStatus = .unauthorized
                    }
                    self.tokenPersister.clearCredentials()
                    completionHandler?(response, context)
                }
            })
        }
        
        if networkRequest is AuthorizedRequest {
            
            return super.sendRequest(networkRequest, completionHandler: { (response, context) in
                
                let group = DispatchGroup()
                
                group.enter()
                var needResend = false
                var wasRefreshTokenSuccessful = true
                
                if !response.isSuccess {
                    let statusCode: Int = context?.response?.statusCode ?? -1
                    
                    if let errorMessage = context?.error?.localizedDescription {
                        print("Server error code \(statusCode)  at method: \(networkRequest.URL), \(errorMessage)")
                    }
                    
                    if statusCode == NetworkStatusCodes.unauthorized.rawValue {
                        
                        group.enter()
                        self.refreshToken({
                            (token) in
                            if let token = token {
                                needResend = true
                                wasRefreshTokenSuccessful = true
                                self.tokenPersister.setToken(token)
                            }
                            group.leave()
                        })
                    }
                }
                
                group.leave()
                
                group.notify(queue: DispatchQueue.main, execute: {
                    if needResend {
                        self.sendRequest(networkRequest, completionHandler: completionHandler)
                    } else {
                        completionHandler?(response, context)
                    }
                    let token = self.tokenPersister.getToken()
                    if !wasRefreshTokenSuccessful && token != nil {
                        //self.delegate?.clientHasInvalidatedToken(self)
                    }
                })
            })
        }
        
        return super.sendRequest(networkRequest, completionHandler: completionHandler)
    }
    
    func refreshToken(_ completionHandler: @escaping ((AccessToken?) -> Void)) {
        //TODO: Implement
        completionHandler(nil)
    }
}
