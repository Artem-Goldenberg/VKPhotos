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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        

        // Do any additional setup after loading the view.
        
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("ViewDidAppear")
        
        if let loginVC = storyboard?.instantiateViewController(identifier: "login") as? LoginViewController {
            print("Instantiated")
            loginVC.photoFetcher = photoFetcher
            present(loginVC, animated: true) { [weak self] in
                guard let self = self else { return }
                self.loadedPhotos = Array(repeating: UIImage(), count: self.photoFetcher.photos.count)
                self.loadImages()
            }
        }
    }
    
    private func loadImages() {
        for (index, photo) in photoFetcher.photos.enumerated() {
            URLSession.shared.dataTask(with: photo.photo_1280) { [weak self] data, response, error in
                guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                    let data = data, error == nil,
                    let image = UIImage(data: data)
                else {
                    print("Failed")
                    return
                }
                DispatchQueue.main.async() {
                    print("Image fetched")
                    self?.loadedPhotos[index] = image
                    self?.collectionView.reloadData()
                }
            }.resume()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoFetcher.photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PhotoCell else {
            print("Fail to dequeue photo cell")
            
            return UICollectionViewCell()
        }
    
        cell.photo.image = loadedPhotos[indexPath.row]
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
