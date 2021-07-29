//
//  ImageViewController.swift
//  VKPhotos
//
//  Created by Artem Goldenberg on 27.07.2021.
//

import UIKit

// Отображает стандартное предупреждение в выбранном vc
func presentAlert(title: String, message: String, vc: UIViewController) {
    let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK", style: .default))
    vc.present(ac, animated: true)
}

class ImageViewController: UIViewController {
    
    // MARK: -Constants
    
    private struct Storyboard {
        static let collectionViewSpaceToBottom: CGFloat = 80
    }
    
    // MARK: -Properties
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var image: UIImage?
    var date: Date?
    
    @IBOutlet weak var collectionView: UICollectionView!
    var allPhotos = [UIImage]()
    
    // MARK: -Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let date = date {
           title = string(from: date)
        }
        
        if let image = image {
            imageView.image = image
        }
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        navigationItem.rightBarButtonItem = shareButton
        
        configureScrollView()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        setUpLayout()
    }
    
    // MARK: -Share button
    
    @objc private func shareTapped() {
        guard let imageToSave = image?.jpegData(compressionQuality: 1.0) else {
            presentAlert(title: "Ошибка", message: "Не удается сжать фотографию", vc: self)
            return
        }
        let actionVC = UIActivityViewController(activityItems: [imageToSave], applicationActivities: [])
        
        actionVC.completionWithItemsHandler = { [weak self] _, completed ,_,_ in
            if completed {
                if let self = self {
                    presentAlert(title: "Готово", message: "Фотография успешно сохранена", vc: self)
                }
            }
        }
        
        present(actionVC, animated: true)
    }
    
    // MARK: -Private functions
    
    private func string(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"
        
        return formatter.string(from: date)
    }
    
    private func configureScrollView() {
        let scrollViewSize = scrollView.bounds.size
        let imageSize = imageView.bounds.size
        let widthScale = scrollViewSize.width / imageSize.width
        let heightScale = scrollViewSize.height / imageSize.height
        let minScale = min(widthScale, heightScale)
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 4.0
        
        scrollView.zoomScale = minScale
    }
    
    private func configureImage() {
        let scrollViewSize = scrollView.bounds.size
        let imageViewSize = imageView.frame.size
        
        let horizontalSpace = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        let verticalSpace = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        
        var extra = navigationController?.navigationBar.bounds.size.height ?? 0
        
        extra += collectionView.frame.height + Storyboard.collectionViewSpaceToBottom
        
        scrollView.contentInset = UIEdgeInsets(top: verticalSpace - extra,
                                               left: horizontalSpace,
                                               bottom: verticalSpace,
                                               right: horizontalSpace)
    }
}

// MARK: -UIScrollViewDelegate

extension ImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

// MARK: -UICollectionViewDataSource

extension ImageViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        allPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "miniPhoto", for: indexPath) as? PhotoCell else {
            fatalError("Cannot dequeue cell with identifier 'miniPhoto'")
        }
        
        cell.photo.image = allPhotos[indexPath.item]
        
        return cell
    }
}

// MARK: -UICollectionViewDelegateFlowLayout

extension ImageViewController: UICollectionViewDelegateFlowLayout {
    private func setUpLayout() {
        let collectionViewHeight = collectionView.frame.height
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: collectionViewHeight, height: collectionViewHeight)
        }
    }
}

// MARK: -UICollectionViewDelegate

extension ImageViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        imageView.image = allPhotos[indexPath.item]
    }
}
