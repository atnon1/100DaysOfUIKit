//
//  DetailViewController.swift
//  Milestone 1
//
//  Created by Anton Makeev on 20.02.2021.
//

import UIKit

class DetailViewController: UIViewController {
    
    
    @IBOutlet weak var imageView: UIImageView!
    var selectedCountry: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let countryToLoad = selectedCountry {
            imageView.image = UIImage(named: countryToLoad)
            imageView.layer.borderWidth = 1
            imageView.layer.borderColor = UIColor.lightGray.cgColor
        }
        title = selectedCountry?.uppercased()
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
    }
    
    @objc func shareTapped() {
        
        guard let image = imageView.image?.jpegData(compressionQuality: 0.8) else {
            print("Image is not found")
            return
        }
        let vc = UIActivityViewController(activityItems: [image, selectedCountry?.uppercased() as Any], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    

}
