//
//  ViewController.swift
//  Project10
//
//  Created by Anton Makeev on 08.03.2021.
//

import UIKit
import LocalAuthentication

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var people = [Person]()
    var isAuthenticated = false {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPerson))
        askAuthentication()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(cancelAuthentication), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(askAuthentication), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func cancelAuthentication() {
        isAuthenticated = false
    }
    
    @objc func askAuthentication() {
        guard !isAuthenticated else {
            return
        }
        var error: NSError?
        let context = LAContext()
        let reason = "Identify yourself!"
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, error in
                DispatchQueue.main.async {
                    if success {
                        self?.isAuthenticated = true
                    } else {
                        let ac = UIAlertController(title: "Authentication failed", message: nil, preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default) { _ in self?.askAuthentication() } )
                        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                        self?.present(ac, animated: true)
                    }
                }
            }
        } else {
            isAuthenticated = true
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isAuthenticated {
            return people.count
        } else {
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Unable to dequeue PersonCell.") }
        let person = people[indexPath.item]
        cell.name.text = person.name
        
        let path = getDocumentDirectory().appendingPathComponent(person.image)
        if let image = UIImage(contentsOfFile: path.path) {
            cell.imageView.image = image
        }
        cell.imageView.layer.cornerRadius = 3
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        let imageName = UUID().uuidString
        let imagePath = getDocumentDirectory().appendingPathComponent(imageName)
        if let jpegImage = image.jpegData(compressionQuality: 0.8) {
            try? jpegImage.write(to: imagePath)
        }
        
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        collectionView.reloadData()
        
        dismiss(animated: true)
    }
    
    func getDocumentDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
    }
    
    @objc func addPerson() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        }
        present(picker, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = people[indexPath.item]
        
        let ac = UIAlertController(title: "Rename person:", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "OK", style: .default) {
            [weak self, weak ac] _ in
            guard let name = ac?.textFields?[0].text else { return }
            person.name = name
            
            self?.collectionView.reloadData()
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .default))
        
        let ac1 = UIAlertController(title: "Rename or Delete?", message: nil, preferredStyle: .alert)
        ac1.addAction(UIAlertAction(title: "Rename", style: .default) {
            [weak self] _ in
            self?.present(ac, animated: true)
        })
        ac1.addAction(UIAlertAction(title: "Cancel", style: .default))
        
        ac1.addAction(UIAlertAction(title: "Remove", style: .destructive) {
            [weak self] _ in
            self?.people.remove(at: indexPath.item)
            self?.collectionView.reloadData()
        })
        
        present(ac1, animated: true)
        
        
    }
    
    
}

