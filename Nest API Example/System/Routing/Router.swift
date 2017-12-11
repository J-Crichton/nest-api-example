//
//  Router.swift
//  Nest API Example
//
//  Created by Eugene on 11/12/2017.
//  Copyright © 2017 Eugene Martinson. All rights reserved.
//

import Foundation
import UIKit

final class UniversalRouter: Router {
    func showAuthorizedMain() {
        let main = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        mainWindow?.rootViewController = main
    }
    
    private var mainWindow: UIWindow?
    
    public static let shared = UniversalRouter()
    
    public func inject(_ window: UIWindow) {
        mainWindow = window
        
        showAuthorizedMain()
        mainWindow?.makeKeyAndVisible()
    }
    
    public func showAuthorization() {
        
        if let topController = UIApplication.topViewController(),
            let authorizationViewController = UIStoryboard(name: "Authorization", bundle: nil).instantiateInitialViewController() {
            topController.present(authorizationViewController, animated: true, completion: {
                
            })
        } else {
            fatalError("`Authorization.storyboard` not found")
        }
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
