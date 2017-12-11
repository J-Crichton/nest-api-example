//
//  AuthViewController.swift
//  Nest API Example
//
//  Created by Eugene on 11/12/2017.
//  Copyright © 2017 Eugene Martinson. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class AuthorizationViewController: UIViewController {

    let model = AuthViewModel()
    
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.loadRequest(URLRequest(url: model.authURL))
        webView.delegate = self
        
        model.state.asObservable()
            .map { text -> String? in
                return self.model.textForState()
            }
            .bind(to: self.progressLabel.rx.text)
            .disposed(by: self.disposeBag)
    }
}

extension AuthorizationViewController: UIWebViewDelegate {
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        guard let url = request.url
            else {
                return false
        }
        
        if let code = model.extractCode(from: url) {
            model.authorize(with: code, { (error) in
                if error == nil {
                    SystemContext.router.showAuthorizedMain()
                }
            })
            
            return false
        }
        
        return true
    }
}
