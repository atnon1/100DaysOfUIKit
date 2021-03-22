//
//  ViewController.swift
//  Mileston 13-15
//
//  Created by Anton Makeev on 19.03.2021.
//

import UIKit

class ViewController: UITableViewController {

    var countries = [Country]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var data: Data?
        navigationController?.navigationBar.prefersLargeTitles = true
        
        if let json = UserDefaults.standard.data(forKey: "countries") {
            data = json
        } else {
            if let url = Bundle.main.url(forResource: "countries", withExtension: "json") {
                if let json = try? Data(contentsOf: url) {
                    data = json
                }
            }
        }
        if let data = data {
            do {
            let decodedData = try JSONDecoder().decode([Country].self, from: data)
                countries = decodedData
            } catch {
                print(error.localizedDescription)
            }
        }
        
        title = "Countries"
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        countries.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(identifier: "Detail") as? DetailViewController else { fatalError("Detail is not found") }
        vc.country = countries[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "countryCell") as? CountryCell else { fatalError("Unable to find Country Cell") }
        let country = countries[indexPath.row]
        cell.label.text = country.name
        cell.flag?.image = UIImage(named: country.flagFileName)
        cell.flag?.layer.borderWidth = 0.5
        cell.flag?.layer.borderColor = UIColor.lightGray.cgColor
        return cell
    }

}

