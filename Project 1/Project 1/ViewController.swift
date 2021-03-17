//
//  ViewController.swift
//  Project 1
//
//  Created by Anton Makeev on 17.02.2021.
//

import UIKit

class ViewController: UITableViewController {

    var pictures = [String]()
    var showCounts = [String : Int]() {
        didSet {
            save()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Storm Viewer"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            [weak self] in
            let fm = FileManager.default
            let path = Bundle.main.resourcePath!
            let items = try! fm.contentsOfDirectory(atPath: path)
            for item in items {
                if item.hasPrefix("nssl") {
                    self?.pictures.append(item)
                }
            }
            self?.pictures.sort()
            print(self?.pictures ?? "")
            
            let defaults = UserDefaults.standard
            self?.showCounts = (defaults.dictionary(forKey: "showCounts") as? [String : Int]) ?? [String : Int]()
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pictureName = pictures[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        cell.textLabel?.text = pictureName
        cell.detailTextLabel?.text = "\(showCounts[pictureName] ?? 0) times shown"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            let pictureName = pictures[indexPath.row]
            showCounts[pictureName] = (showCounts[pictureName] ?? 0) + 1
            vc.selectedImage = pictureName
            vc.orderNumber = indexPath.row + 1
            vc.picturesNumber = pictures.count
            tableView.reloadRows(at: [indexPath], with: .automatic)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func save() {
        let defaults = UserDefaults.standard
        defaults.setValue(showCounts, forKeyPath: "showCounts")
    }
}

