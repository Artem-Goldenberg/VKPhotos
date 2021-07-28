//
//  PhotoCollectionViewController.swift
//  VKPhotos
//
//  Created by Artem Goldenberg on 26.07.2021.
//

import UIKit

class PhotoCollectionViewController: UICollectionViewController {
    var photoFetcher: VKPhotoFetcher!
    var loadedPhotos = [UIImage]()
    
    // MARK: -Constants
    
    struct Storyboard {
        static let reuseIdentifier = "Photo"
        
        static let sidePadding: CGFloat = 1
        static let itemsPerRow: CGFloat = 2
    }
    
    // MARK: -Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Mobile Up Gallery"
        
        let collectionViewWidth = collectionView.frame.width
        let itemWidth = (collectionViewWidth - Storyboard.sidePadding) / Storyboard.itemsPerRow
        //itemWidth = 200
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        }
        
        loadedPhotos = Array(repeating: UIImage(), count: photoFetcher.photos.count)
        loadImages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        
        navigationItem.hidesBackButton = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(false)
        
        navigationItem.hidesBackButton = false
    }
    
    // MARK: -Login button
    
    @IBAction func logout(_ sender: Any) {
        photoFetcher.logout()
        navigationController?.popViewController(animated: true)
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
                        
                        let path = IndexPath(item: index, section: 0)
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.reuseIdentifier, for: indexPath) as? PhotoCell else {
            print("Fail to dequeue photo cell")
            
            return UICollectionViewCell()
        }
    
        cell.photo.image = loadedPhotos[indexPath.item]
        cell.photo.layer.borderWidth = 2.0
        cell.photo.layer.borderColor = UIColor.black.cgColor
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "imageView") as? ImageViewController {
            vc.image = loadedPhotos[indexPath.item]
            
            let date = photoFetcher.photos[indexPath.item].date
            vc.date = Date(timeIntervalSince1970: TimeInterval(date))
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

