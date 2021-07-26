//
//  VKLoginner.swift
//  VKPhotos
//
//  Created by Artem Goldenberg on 25.07.2021.
//

import Foundation
import UIKit

class VKLoginner: NSObject {
    var id: String
    var token: String
    
    var name: String
    var photos: [UIImage]
    
    override init() {
        id = UserDefaults.standard.string(forKey: VKLoginner.idKey) ?? ""
        token = UserDefaults.standard.string(forKey: VKLoginner.tokenKey) ?? ""
        
        name = ""
        photos = []
    }
    
    func loginWith(parameters: [String: String]) {
        id = parameters["user_id"]! //handle
        token = parameters["access_token"]! //handle
        
        UserDefaults.standard.set(id, forKey: VKLoginner.idKey)
        UserDefaults.standard.set(token, forKey: VKLoginner.tokenKey)
        
        let requestString = "https://api.vk.com/method/users.get?user_ids=\(id)&v=5.21&access_token=\(token)"
        
        let request = URLRequest(url: URL(string: requestString)!)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Filed to get a name \(error.localizedDescription)")
            } else if let data = data {
                DispatchQueue.main.async {
                    if let responseString = String(data: data, encoding: .utf8) {
                       // let userData = responceString.components(separatedBy: "\":{},[]")
                        //self?.name = userData[14] + " " + userData[20]
                        print("RESPONSE: \(responseString)")
                      //  print(self?.name)
                    } else {
                        print("Cannot decode string")
                    }
                }
            } else {
                print("DATA NOT FOUND")
            }
        }.resume()
    }
    
    private static let idKey = "id"
    private static let tokenKey = "token"
}

