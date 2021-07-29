//
//  ViewController.swift
//  VKPhotos
//
//  Created by Artem Goldenberg on 25.07.2021.
//

import UIKit
import WebKit

class LoginViewController: UIViewController {
    
    // MARK: -Properties
    
    var webView: WKWebView!
    var photoFetcher: VKPhotoFetcher!
    
    // MARK: -Lifecycle
    
    override func loadView() {
        super.loadView()
        
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlString = "https://oauth.vk.com/authorize?client_id=7911455&scope=wall,offline&redirect_uri=oauth.vk.com/blank.html&display=touch&response_type=token"
        let request = URLRequest(url: URL(string: urlString)!)
        
        webView.load(request)
    }
}

// MARK: -WKNavigationDelegate

extension LoginViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let currentURL = webView.url?.absoluteString else {
            presentAlert(title: "Ошибка", message: "Неудалось получить URL", vc: self)
            return
        }
        // check if we are on the response page
        print(currentURL)
        guard currentURL.contains("https://oauth.vk.com/blank.html") else {
            return
        }
        
        var user = [String: String]()
        
        if currentURL.contains("access_token") {
            //parse url
            guard let token = currentURL.value(for: "access_token"),
                  let expiresIn = currentURL.value(for: "expires_in"),
                  let userId = currentURL.value(for: "user_id")
            else {
                presentAlert(title: "Ошибка", message: "Сбрй сервера", vc: self)
                return
            }
            user["access_token"] = token
            user["expires_in"] = expiresIn
            user["user_id"] = userId
            
            photoFetcher.loginWith(parameters: user)
        } else {
            if currentURL.value(for: "error_reason") == "user_denied" {
                dismiss(animated: true)
            } else {
                presentAlert(title: "Ошибка сети", message: "Неизвестная ошибка", vc: presentingViewController ?? self)
            }
        }
        
        dismiss(animated: true)
    }
}

// MARK: -Utility extensions

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
