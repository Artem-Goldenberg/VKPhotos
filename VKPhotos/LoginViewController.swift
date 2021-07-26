//
//  ViewController.swift
//  VKPhotos
//
//  Created by Artem Goldenberg on 25.07.2021.
//

import UIKit
import WebKit

class LoginViewController: UIViewController {
    var webView: WKWebView!
    var photoFetcher: VKPhotoFetcher!
    
    override func loadView() {
        super.loadView()
        
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.load(URLRequest(url: URL(string: "https://oauth.vk.com/authorize?client_id=7911455&scope=wall,offline&redirect_uri=oauth.vk.com/blank.html&display=touch&response_type=token")!))
    }
}

extension LoginViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let currentURL = webView.url?.absoluteString else {
            //Handle Error
            return
        }
        // check if we are on the response page
        guard currentURL.contains("https://oauth.vk.com/blank.html") else { return }
        
        var user = [String: String]()
        
        print("\(currentURL)")
        if currentURL.contains("access_token") {
            //parse url
            let token = currentURL.value(for: "access_token")! // handle
            print("TOKEN: \(token)")
            user["access_token"] = token
            user["expires_in"] = currentURL.value(for: "expires_in")! // handle
            user["user_id"] = currentURL.value(for: "user_id")! // handle
            
            photoFetcher.loginWith(parameters: user)
        } else {
            print("TOKEN NOT FOUND")
        }
    }
}

extension String {
    // methods for correctly parsing access information from the https://oauth.vk.com/blank.html
    func value(for word: String) -> String? {
        let data = components(separatedBy: "=")
        
        if let prevIndex = data.firstIndex(where: { $0.contains(word) }) {
            if prevIndex != data.index(before: data.endIndex) {
                let string = data[data.index(after: prevIndex)]
                return string.characters(before: "&")
            }
        }
        
        return nil
    }
    
    func characters(before stopChar: Character) -> String {
        if let stopIndex = firstIndex(of: stopChar) {
            return String(self[startIndex..<stopIndex])
        }
        
        return self
    }
}

