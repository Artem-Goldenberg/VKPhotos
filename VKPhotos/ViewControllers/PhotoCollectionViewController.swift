//
//  PhotoCollectionViewController.swift
//  VKPhotos
//
//  Created by Artem Goldenberg on 26.07.2021.
//

import UIKit

private let reuseIdentifier = "Photo"

class PhotoCollectionViewController: UICollectionViewController {
    var photoFetcher = VKPhotoFetcher()
    var loadedPhotos = [UIImage]()
    
    // MARK: -Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Все фото"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        photoFetcher.delegate = self
        photoFetcher.isTokenValid()
    }
    
    
    // MARK: -Login button
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        photoFetcher.logout()
    }
    
    
    // MARK: -Image loading logic
   
    private func loadImages() {
        for (index, photo) in photoFetcher.photos.enumerated() {
            URLSession.shared.dataTask(with: photo.photo_1280) { [weak self] data, response, error in
                guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                    let data = data, error == nil
                else {
                    DispatchQueue.main.async {
                        if let self = self {
                            presentAlert(title: "Ошибка сети", message: "Не удалось загрузить фотографии", vc: self)
                        }
                    }
                    return
                }
                guard let image = UIImage(data: data) else {
                    DispatchQueue.main.async {
                        if let self = self {
                            presentAlert(title: "Ошибка", message: "Не удалось распознать фотографии", vc: self)
                        }
                    }
                    return
                }
                DispatchQueue.main.async() {
                    if let self = self {
                        self.loadedPhotos[index] = image
                        
                        let path = IndexPath(row: index, section: 0)
                        self.collectionView.reloadItems(at: [path])
                    }
                   
                }
            }.resume()
        }
    }

    // MARK: -UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return loadedPhotos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PhotoCell else {
            print("Fail to dequeue photo cell")
            
            return UICollectionViewCell()
        }
    
        cell.photo.image = loadedPhotos[indexPath.row]
        cell.photo.layer.borderWidth = 2.0
        cell.photo.layer.borderColor = UIColor.black.cgColor
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "imageView") as? ImageViewController {
            vc.image = loadedPhotos[indexPath.row]
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: -VKPhotoFetcherDelegate

extension PhotoCollectionViewController: VKPhotoFetcherDelegate {
    func didFinishFetchingPhotos() {
        loadedPhotos = Array(repeating: UIImage(), count: photoFetcher.photos.count)
        loadImages()
        print("Finished")
        collectionView.reloadData()
    }
    
    func didFinishCheckingTokenAvailability(with answer: Bool) {
        if !answer {
            if let loginVC = storyboard?.instantiateViewController(identifier: "login") as? LoginViewController {
                loginVC.photoFetcher = photoFetcher
                present(loginVC, animated: true)
            }
        } else { // if token from previous session is available than it must be saved in the photoFetcher
            var user = [String: String]()
            user["access_token"] = photoFetcher.token
            user["user_id"] = photoFetcher.id
            
         
            photoFetcher.loginWith(parameters: user)
        }
    }
    func didFinishCheckingTokenAvailabilityWithError(error: String) {
        presentAlert(title: "Ошибка авторизации", message: error, vc: self)
    }
}
