//
//  ViewController.swift
//  Milestone4-6
//
//  Created by Anton Makeev on 28.02.2021.
//

import UIKit

class ViewController: UITableViewController {
    
    var items = [String]() {
        didSet {
            navigationItem.leftBarButtonItem?.isEnabled = !items.isEmpty
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(clearList))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        navigationItem.leftBarButtonItem?.isEnabled = !items.isEmpty
        tableView.reloadData()
    }

    
    @objc func clearList() {
        let ac = UIAlertController(title: "Do you want to remove all items?", message: nil, preferredStyle: .alert)
        let remove = UIAlertAction(title: "Remove all", style: .destructive) {
            [weak self] _ in
            self?.items.removeAll()
            self?.tableView.reloadData()
        }
        
        ac.addAction(remove)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
        
    }
    
    @objc func addItem() {
        let ac = UIAlertController(title: "Add item to shopping list", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submit = UIAlertAction(title: "Add", style: .default) {
            [weak self, weak ac] _ in
            guard let item = ac?.textFields?[0].text else { return }
            self?.submit(item)
        }
        ac.addAction(submit)
        present(ac, animated: true)
    }
    
    func submit(_ item: String) {
        items.insert(item, at: 0)
        tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
    }
    
    @ objc func shareTapped() {
        let vc = UIActivityViewController(activityItems: [items.joined(separator: "\n")], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count + 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            addItem()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "addItemCell", for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
            cell.textLabel?.text = items[indexPath.row - 1]
        }
        return cell
    }
    

}

