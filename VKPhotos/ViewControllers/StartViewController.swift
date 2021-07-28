//
//  StartViewController.swift
//  VKPhotos
//
//  Created by Artem Goldenberg on 28.07.2021.
//

import UIKit

class StartViewController: UIViewController {
    
    // MARK: -Properties
    
    @IBOutlet weak var loginButton: UIButton!
    
    let photoFetcher = VKPhotoFetcher()
    
    var buttonPressed = false // приходится использовать дополнительную переменную чтобы отличить вход с нажатия на кнопку и просто открытие приложения
    
     // MARK: -Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loginButton.layer.cornerRadius = 10
        photoFetcher.delegate = self
        photoFetcher.isTokenValid()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: -Login button
    
    @IBAction func loginButtonTapped() {
        photoFetcher.isTokenValid()
        buttonPressed = true
    }
}

// MARK: -VKPhotoFetcherDelegate

extension StartViewController: VKPhotoFetcherDelegate {
    func didFinishCheckingTokenAvailability(with answer: Bool) {
        if !answer {
            if buttonPressed {
                if let loginVC = storyboard?.instantiateViewController(identifier: "login") as? LoginViewController {
                    loginVC.photoFetcher = photoFetcher
                    present(loginVC, animated: true)
                } else {
                    fatalError("Cannot dequeue with ViewController with identifier 'login'")
                }
            }
        } else {
            var user = [String: String]()
            user["access_token"] = photoFetcher.token
            user["user_id"] = photoFetcher.id
            
            print("trying to login")
            photoFetcher.loginWith(parameters: user)
        }
    }
    
    func didFinishFetchingPhotos() {
        if let photoCollectionVC = storyboard?.instantiateViewController(identifier: "photos") as? PhotoCollectionViewController {
            photoCollectionVC.photoFetcher = photoFetcher
            navigationController?.pushViewController(photoCollectionVC, animated: true)
        }
    }
    
    func didFinishCheckingTokenAvailabilityWithError(error: String) {
        presentAlert(title: "Ошибка авторизации", message: error, vc: self)
    }
    
    func didFinishFetchingPhotosWithError(error: String) {
        presentAlert(title: "Не удалось получить фотографии", message: error, vc: self)
    }
}
