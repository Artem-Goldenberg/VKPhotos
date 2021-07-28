//
//  ImageViewController.swift
//  VKPhotos
//
//  Created by Artem Goldenberg on 27.07.2021.
//

import UIKit

func presentAlert(title: String, message: String, vc: UIViewController) {
    let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK", style: .default))
    vc.present(ac, animated: true)
}

class ImageViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage?
    var date: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = false
        
        if let date = date {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ru_RU")
            formatter.dateFormat = "d MMMM yyyy"
            
            
            title = formatter.string(from: date)
        }
        
        if let image = image {
            imageView.image = image
        }
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
        navigationItem.rightBarButtonItem = shareButton
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.hidesBarsOnTap = true
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        navigationController?.hidesBarsOnTap = false
//    }
    
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
}
