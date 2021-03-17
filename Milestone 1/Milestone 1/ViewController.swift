//
//  ViewController.swift
//  Milestone 1
//
//  Created by Anton Makeev on 19.02.2021.
//

import UIKit

class FlagCell: UITableViewCell {
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var flagImage: UIImageView!
    
}


class ViewController: UITableViewController {

    var countries = [String]()
    override func viewDidLoad() {
        
        super.viewDidLoad()
        title = "Flags"
        navigationController?.navigationBar.prefersLargeTitles = true
        countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]

    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let countryName = countries[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "FlagCell", for: indexPath) as! FlagCell
        cell.countryNameLabel?.text = countryName.uppercased()
        cell.flagImage?.image = UIImage(named: countryName)
        cell.flagImage?.layer.borderWidth = 1
        cell.flagImage?.layer.borderColor = UIColor.lightGray.cgColor
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let country = countries[indexPath.row]
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.selectedCountry = country
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }

}



