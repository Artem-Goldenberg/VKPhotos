//
//  VKLoginner.swift
//  VKPhotos
//
//  Created by Artem Goldenberg on 25.07.2021.
//

import Foundation

let serviceToken = "711e6061711e6061711e6061cf7166d87e7711e711e606111e3d80bbb61c32b6b81762a"
let securityKey = "svhRvLbzul5mC3BWM8CJ"
let appId = "7911455"
let testId = "153415127"

class VKPhotoFetcher: NSObject {
    var id: String
    var token: String
    var delegate: VKPhotoFetcherDelegate?
    
    var photos: [Photo]
    
    override init() {
        id = UserDefaults.standard.string(forKey: VKPhotoFetcher.idKey) ?? ""
        token = UserDefaults.standard.string(forKey: VKPhotoFetcher.tokenKey) ?? ""
        
        photos = []
    }
    
    func isTokenValid() {
        let requestString = "https://api.vk.com/method/secure.checkToken?token=\(token)&v=5.21&access_token=\(serviceToken)"
        
        var request = URLRequest(url: URL(string: requestString)!)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let data = data {
                DispatchQueue.main.async {
                    if let decoded = try? JSONDecoder().decode(TokenAvailabilityRoot.self, from: data) {
                        print("AVAILABLE: \(decoded.response.success)")
                        self?.delegate?.didFinishCheckingTokenAvailability(with: decoded.response.success == 1)
                    } else {
                        self?.delegate?.didFinishCheckingTokenAvailability(with: false)
                        print("FAILED to decode data: \(String(data: data, encoding: .utf8) ?? "no description")")
                        print("Error decoding a response for request: \(requestString)")
                    }
                }
            } else if let error = error {
                print("Error checking the token: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func loginWith(parameters: [String: String]) {
        id = parameters["user_id"]! //handle
        token = parameters["access_token"]! //handle
        
        UserDefaults.standard.set(id, forKey: VKPhotoFetcher.idKey)
        UserDefaults.standard.set(token, forKey: VKPhotoFetcher.tokenKey)
        
        let requestString = "https://api.vk.com/method/photos.get?owner_id=-128666765&album_id=266276915&v=5.21&access_token=\(token)"
        
        var request = URLRequest(url: URL(string: requestString)!)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Filed to get a name \(error.localizedDescription)")
            } else if let data = data {
                DispatchQueue.main.async {
                    self?.fetchPhotos(from: data)
                    self?.delegate?.didFinishFetchingPhotos()
                }
            } else {
                print("DATA NOT FOUND")
            }
        }.resume()
    }
    
    private func fetchPhotos(from response: Data) {
        if let root = try? JSONDecoder().decode(PhotoRequestRoot.self, from: response) {
            photos = root.response.items
            print("PHOTOS: \(photos)")
        } else {
            print("Fail to decode: \(String(data: response, encoding: .utf8) ?? "no string interpretation")")
        }
    }
    
    func logout() {
        token = ""
        id = ""
        UserDefaults.standard.removeObject(forKey: VKPhotoFetcher.idKey)
        UserDefaults.standard.removeObject(forKey: VKPhotoFetcher.tokenKey)
        
        
    }
    
    struct TokenAvailabilityRoot: Codable {
        var response: TokenAvailabilityResponse
    }
    
    struct TokenAvailabilityResponse: Codable {
        var success: Int
    }
    
    struct PhotoRequestRoot: Codable {
        var response: PhotoRequestResponse
    }
    
    struct PhotoRequestResponse: Codable {
        var items: [Photo]
    }
    
    struct Photo: Codable {
        var photo_1280: URL
    }
    
    private static let idKey = "id"
    private static let tokenKey = "token"
}

protocol VKPhotoFetcherDelegate {
    func didFinishFetchingPhotos()
    func didFinishCheckingTokenAvailability(with answer: Bool)
}
