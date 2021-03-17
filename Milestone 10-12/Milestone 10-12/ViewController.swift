//
//  ViewController.swift
//  Milestone 10-12
//
//  Created by Anton Makeev on 13.03.2021.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imageNames = [PictureStruct]() {
        didSet {
            if let json = try? JSONEncoder().encode(imageNames) {
                UserDefaults.standard.setValue(json, forKey: "imageNames")
            }
        }
    }
    
    var images = [String : UIImage]()

    func loadData() {
        DispatchQueue.global().async {
            [weak self] in
            if let data = UserDefaults.standard.data(forKey: "imageNames") {
                if let names = try? JSONDecoder().decode([PictureStruct].self, from: data) {
                    self?.imageNames = names
                    for name in names {
                        let path = self?.getDocumentDirectory().appendingPathComponent(name.pathName)
                        if let picImage = UIImage(contentsOfFile: path!.path) {
                            self?.images[name.pathName] = picImage
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPicture))
        title = "Photos"
        loadData()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let picture = info[.editedImage] as? UIImage else { return }
        let pathName = UUID().uuidString
        let path = getDocumentDirectory().appendingPathComponent(pathName)
        if let jpedPicture = picture.jpegData(compressionQuality: 0.8) {
            try? jpedPicture.write(to: path)
        }
        dismiss(animated: true)
        imageNames.append(PictureStruct(pathName: pathName, name: "Unknown"))
        images[pathName] = picture
        nameLastPicture()
    }
    
    func nameLastPicture() {

        let ac = UIAlertController(title: "Name the picture", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "OK", style: .default) {
            [weak self] _ in
            let name = ac.textFields![0].text!
            if let names = self?.imageNames {
                if var pic = names.last {
                    pic.name = name
                    self?.imageNames[names.count - 1] = pic
                }
            }
            self?.collectionView.reloadData()
        } )
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @objc func addPicture() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        }
        present(picker, animated: true)
    }

    func getDocumentDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Picture", for: indexPath) as? Picture else { fatalError("There is a proble with Item") }
        let pic = imageNames[indexPath.item]
        if let picImage = images[pic.pathName] {
            cell.image.image = picImage
        }
        cell.label.text = pic.name
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.image.layer.borderWidth = 0.5
        cell.image.layer.borderColor = UIColor.lightGray.cgColor
        return cell
    }

    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageNames.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "Detail") as? DetailViewController {
            let picStruct = imageNames[indexPath.item]
            if let image = images[picStruct.pathName] {
                vc.image = image
            }
            vc.name = picStruct.name
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

