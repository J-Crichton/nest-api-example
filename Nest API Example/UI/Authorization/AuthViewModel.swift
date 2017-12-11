//
//  AuthViewModel.swift
//  Nest API Example
//
//  Created by Eugene on 11/12/2017.
//  Copyright © 2017 Eugene Martinson. All rights reserved.
//

import Foundation
import RxSwift

class AuthViewModel: ViewStateLoadable {
    var state: Variable<ViewLoadingState> = Variable(.loading)
    
    var authURL: URL {
        get {
            let uniqueState = "\(Bundle.main.bundleIdentifier!)_\(UUID().uuidString)"
            let clientID = NestConstants.clientID
            return URL(string: "https://home.nest.com/login/oauth2?client_id=\(clientID)&state=\(uniqueState)")!
        }
    }
    
    public func extractCode(from url: URL) -> String? {
        if url.host == redirectURL.host {
            guard let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: false),
                let queryItems = urlComponents.queryItems,
                let code = queryItems.filter({ $0.name == "code" }).first?.value else { return nil }
            
            return code
        }
        return nil
    }
    
    var redirectURL = URL(string: NestConstants.authRedirectUri)!
    
    func textForState() -> String {
        switch state.value {
        case .loading: return "Authorization"
        case .failed(let error): return error.localizedDescription
        case .success: return "Authorized"
        }
    }
    
    public func authorize(with code: String, _ completion: @escaping CompletionHandler) {
        
        SystemContext.shared.nestAPI.authorize(code, completion)
    }
    
    func loadData() {
        
    }
}
