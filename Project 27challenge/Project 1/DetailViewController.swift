//
//  DetailViewController.swift
//  Project 1
//
//  Created by Anton Makeev on 17.02.2021.
//

import UIKit

class DetailViewController: UIViewController {

    
    @IBOutlet var imageView: UIImageView!
    var selectedImage: String?
    var orderNumber = 0
    var picturesNumber = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Picture \(orderNumber) of \(picturesNumber)"
        navigationItem.largeTitleDisplayMode = .never
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
        if let imageToLoad = selectedImage {
            imageView.image = UIImage(named: imageToLoad)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }
    
    @objc func shareTapped() {
        guard let image = watermarkImage(imageView.image)?.jpegData(compressionQuality: 0.8) else {
            print("No image found")
            return
        }
        
        
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }

    func watermarkImage(_ image: UIImage?) -> UIImage? {
        guard let image = image else { return nil }
        let renderer = UIGraphicsImageRenderer(size: image.size)
        let newImage = renderer.image { ctx in
            image.draw(at: CGPoint(x: 0, y: 0))
            ctx.cgContext.rotate(by: .pi / 6)
            let string = NSMutableAttributedString(string: "FROM STORM VIEWER", attributes:  [ .font : UIFont.systemFont(ofSize: 100) ])
            string.draw(with: CGRect(origin: CGPoint(x: 50, y: 10), size: image.size), options: .usesLineFragmentOrigin, context: nil)
        }
        return newImage
    }
    
}
