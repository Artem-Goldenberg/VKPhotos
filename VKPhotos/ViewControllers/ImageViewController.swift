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
    
    // MARK: -Properties
    
    @IBOutlet weak var imageView: UIImageView!
    //@IBOutlet weak var scrollView: UIScrollView!
    var scrollView: UIScrollView!
    
    var image: UIImage?
    var date: Date?
    
    // MARK: -Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //navigationController?.navigationBar.prefersLargeTitles = false
        
        if let date = date {
           title = string(from: date)
        }
        
        if let image = image {
            imageView.image = image
        }
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        navigationItem.rightBarButtonItem = shareButton
        
        configureScrollView()
        configureImage()
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
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.backgroundColor = .white
        scrollView.contentSize = imageView.bounds.size
        scrollView.delegate = self
        scrollView.addSubview(imageView)
        
        view.addSubview(scrollView)
        
        let scrollViewSize = scrollView.bounds.size
        let imageSize = imageView.bounds.size
        let widthScale = scrollViewSize.width / imageSize.width
        let heightScale = scrollViewSize.height / imageSize.height
        let minScale = min(widthScale, heightScale)
        
        scrollView.contentSize = imageView.bounds.size
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 4.0
        
        scrollView.zoomScale = minScale
    }
    
    private func configureImage() {
        let scrollViewSize = scrollView.bounds.size
        let imageViewSize = imageView.frame.size
        
        let horizontalSpace = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        let verticalSpace = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        
        let extra = navigationController?.navigationBar.bounds.size.height ?? 0
        
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
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        configureImage()
    }
}
