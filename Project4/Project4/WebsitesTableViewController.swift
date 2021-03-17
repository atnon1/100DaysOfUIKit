//
//  WebsitesTableViewController.swift
//  Project4
//
//  Created by Anton Makeev on 23.02.2021.
//

import UIKit

class WebsitesTableViewController: UITableViewController {

    var allowedWebsites = ["apple.com", "hackingwithswift.com", "google.com"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Websites"
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allowedWebsites.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let website = allowedWebsites[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Website cell", for: indexPath)
        cell.textLabel?.text = website
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let website = allowedWebsites[indexPath.row]
        if let vc = storyboard?.instantiateViewController(identifier: "Website View Controller") as? ViewController {
            vc.initialWebsite = website
            vc.allowedWebsites = allowedWebsites
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
