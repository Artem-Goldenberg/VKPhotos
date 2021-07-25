//
//  ViewController.swift
//  VKPhotos
//
//  Created by Artem Goldenberg on 25.07.2021.
//

import UIKit
import WebKit

class LoginViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        webView.load(URLRequest(url: URL(string: "https://google.com")!))
    }


}

extension LoginViewController: WKNavigationDelegate {
    
}

