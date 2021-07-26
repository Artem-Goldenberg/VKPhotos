//
//  VKLoginner.swift
//  VKPhotos
//
//  Created by Artem Goldenberg on 25.07.2021.
//

import Foundation

class VKLoginner: NSObject {
    var id: String
    var token: String
    
    var name: String
    var photos: [Photo]
    
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
        
        let requestString = "https://api.vk.com/method/photos.get?owner_id=-128666765&album_id=266276915&v=5.21&access_token=\(token)"
        
        var request = URLRequest(url: URL(string: requestString)!)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Filed to get a name \(error.localizedDescription)")
            } else if let data = data {
                DispatchQueue.main.async {
                    self?.fetchPhotos(from: data)
                }
            } else {
                print("DATA NOT FOUND")
            }
        }.resume()
    }
    
    private func fetchPhotos(from response: Data) {
        if let root = try? JSONDecoder().decode(Root.self, from: response) {
            photos = root.response.items
            print("PHOTOS: \(photos)")
        } else {
            print("Fail to decode: \(String(data: response, encoding: .utf8) ?? "no string interpretation")")
        }
    }
    
    private static let fetchPhotoIdentifier = "photo_1280"
    private static let idKey = "id"
    private static let tokenKey = "token"
}

struct Root: Codable {
    var response: Response
}

struct Response: Codable {
    var items: [Photo]
}

struct Photo: Codable {
    var photo_1280: URL
}
