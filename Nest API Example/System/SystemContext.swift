//
//  SystemContext.swift
//  Nest API Example
//
//  Created by Eugene on 11/12/2017.
//  Copyright © 2017 Eugene Martinson. All rights reserved.
//

import Foundation

public struct NestConstants {
    public static let baseURL = "https://developer-api.nest.com"
    public static let clientID = "925192f6-cf1a-432b-b299-1ce926a166c1"
    public static let secret = "ATa58Ju4JT5PYp3GAZ4DhW4Uf"
    public static let authRedirectUri = "https://example.com"
}

public final class SystemContext {
    
    public static let shared = SystemContext()
    public var nestAPI: NestAPI
    public static var router: Router = UniversalRouter.shared
    
    private init() {
        nestAPI = RESTNestAPI({ status in
            if status == AuthorizationStatus.unauthorized {
                SystemContext.router.showAuthorization()
            }
        })
    }
}
