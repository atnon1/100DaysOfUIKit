//
//  DetailViewController.swift
//  Milestone 10-12
//
//  Created by Anton Makeev on 14.03.2021.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    var image: UIImage?
    var name: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let name = name {
            title = name
        }
        if let image = image {
            imageView.image = image
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationController?.hidesBarsOnTap = false
    }
}
