//
//  TokenPersister.swift
//  Nest API Example
//
//  Created by Eugene on 11/12/2017.
//  Copyright © 2017 Eugene Martinson. All rights reserved.
//

import Foundation

public protocol TokenPersister {
    func getToken() -> AccessToken?
    func setToken(_ token: AccessToken)
    func clearCredentials()
}

enum TokenKeys: String {
    case token, expires_in, type
}

public class DefaultTokenPersister: TokenPersister {
    
    private func key(for key: TokenKeys) -> String {
        return "AuthorizationToken \(key)"
    }
    public func getToken() -> AccessToken? {
        
        guard let value = UserDefaults.standard.value(forKey: key(for: .token)) as? String,
            let expires_in = UserDefaults.standard.value(forKey: key(for: .expires_in)) as? Int,
            let type = UserDefaults.standard.value(forKey: key(for: .type)) as? String
            else {
                return nil
        }
        
        return AccessToken(value: value, expires_in: expires_in, type: type)
    }
    public func setToken(_ token: AccessToken) {
        UserDefaults.standard.setValue(token.access_token, forKey: key(for: .token))
        UserDefaults.standard.setValue(token.expires_in, forKey: key(for: .expires_in))
        UserDefaults.standard.setValue(token.type, forKey: key(for: .type))
    }
    public func clearCredentials() {
        UserDefaults.standard.removeObject(forKey: key(for: .token))
        UserDefaults.standard.removeObject(forKey: key(for: .expires_in))
        UserDefaults.standard.removeObject(forKey: key(for: .type))
    }
}
