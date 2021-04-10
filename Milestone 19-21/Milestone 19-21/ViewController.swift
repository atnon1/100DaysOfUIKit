//
//  ViewController.swift
//  Milestone 19-21
//
//  Created by Anton Makeev on 09.04.2021.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var toolBar: UIToolbar!
    
    var navigationBarObserver: NSKeyValueObservation?
    var backgroundColor: UIColor?
    
    var notes = [Note]() {
        didSet {
            notes.sort { $0.modified > $1.modified }
            save()
        }
    }
    
    var filteredNotes: [Note]  {
        if filterText.isEmpty {
            return notes
        } else {
            return notes.filter { $0.title.lowercased().contains(filterText.lowercased()) }
        }
    }
    
    var filterText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        title = "Notes"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.sizeToFit()
        
        backgroundColor = view.backgroundColor
        //Set navigation transparent
//        navigationController?.navigationBar.isTranslucent = true
        //navigationController?.navigationBar.shadowImage = UIImage()
        navigationBarObserver = self.navigationController?.navigationBar.observe(\.frame, options: [.new], changeHandler: { [weak self] (navigationBar, changes) in
                    if let height = changes.newValue?.height {
                        if height > 46.0 {
                            //Large Title
                            self?.view.backgroundColor = self?.tableView.backgroundColor
                        } else {
                            //Small Title
                            self?.view.backgroundColor = self?.backgroundColor
                        }
                    }
                })
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)

        
        
        //Set searchbar transparent
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        
        tableView.separatorInset = .init(top: 0, left: 24, bottom: 0, right: 0)
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        hideKeyboardWhenTappedAround()
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.setValue(data, forKey: "notes")
        }
    }
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "notes") {
            if let notes = try? JSONDecoder().decode([Note].self, from: data) {
                self.notes = notes
                tableView.reloadData()
            }
        }
    }
    
    @IBAction func createNote(_ sender: UIBarButtonItem) {
        let newNote = Note(body: "", created: Date(), modified: Date())
        notes.insert(newNote, at: 0)
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        showEditor(withNoteAt: 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredNotes.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell") else { fatalError() }
        
        let note = filteredNotes[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        cell.textLabel?.text = note.title
        cell.detailTextLabel?.text = String(dateFormatter.string(from: note.modified))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showEditor(withNoteAt: indexPath.row)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            removeNote(atRow: indexPath.row)
        }
    }
    
    func removeNote(atRow row: Int) {
        guard let index = notes.firstIndex(where: { filteredNotes[row].uuid == $0.uuid }) else { return }
            notes.remove(at: index)
            tableView.deleteRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
    }

    
    func showEditor(withNoteAt row: Int) {
        guard
            let vc = storyboard?.instantiateViewController(identifier: "noteEditor") as? NoteEditorView,
            let index = notes.firstIndex(where: { filteredNotes[row].uuid == $0.uuid })
        else { return }
        vc.vc = self
        vc.row = index
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterText = searchText
        tableView.reloadData()
    }
    
}

