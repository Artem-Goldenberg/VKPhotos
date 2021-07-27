//
//  VKLoginner.swift
//  VKPhotos
//
//  Created by Artem Goldenberg on 25.07.2021.
//

import Foundation

let serviceToken = "711e6061711e6061711e6061cf7166d87e7711e711e606111e3d80bbb61c32b6b81762a"

enum FetchError: Error {
    case network
}

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
                        self?.delegate?.didFinishCheckingTokenAvailability(with: decoded.response.success == 1)
                    } else {
                        self?.delegate?.didFinishCheckingTokenAvailability(with: false)
                    }
                }
            } else if let error = error {
                DispatchQueue.main.async {
                    self?.delegate?.didFinishCheckingTokenAvailabilityWithError(error: error.localizedDescription)
                }
            }
            
        }.resume()
    }
    
    func loginWith(parameters: [String: String]) {
        id = parameters["user_id"] ?? ""
        token = parameters["access_token"] ?? ""
        
        UserDefaults.standard.set(id, forKey: VKPhotoFetcher.idKey)
        UserDefaults.standard.set(token, forKey: VKPhotoFetcher.tokenKey)
        
        let requestString = "https://api.vk.com/method/photos.get?owner_id=-128666765&album_id=266276915&v=5.21&access_token=\(token)"
        
        var request = URLRequest(url: URL(string: requestString)!)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("Error")
                    self?.delegate?.didFinishFetchingPhotosWithError(error: error.localizedDescription)
                }
            } else if let data = data {
                DispatchQueue.main.async {
                    print("Finish")
                    self?.fetchPhotos(from: data)
                    self?.delegate?.didFinishFetchingPhotos()
                }
            } else {
                DispatchQueue.main.async {
                    print("Not finish")
                    self?.delegate?.didFinishFetchingPhotosWithError(error: error?.localizedDescription ?? "")
                }
            }
        }.resume()
    }
    
    private func fetchPhotos(from response: Data) {
        if let root = try? JSONDecoder().decode(PhotoRequestRoot.self, from: response) {
            photos = root.response.items
        } else {
            print("fail")
            let error = "Fail to decode: \(String(data: response, encoding: .utf8) ?? "no string interpretation")"
            delegate?.didFinishCheckingTokenAvailabilityWithError(error: error)
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
    func didFinishFetchingPhotosWithError(error: String)
    func didFinishCheckingTokenAvailabilityWithError(error: String)
}

extension VKPhotoFetcherDelegate {
    func didFinishFetchingPhotos() {}
    func didFinishCheckingTokenAvailability(with answer: Bool) {}
    func didFinishFetchingPhotosWithError(error: String) {}
    func didFinishCheckingTokenAvailabilityWithError(error: String) {}
}
