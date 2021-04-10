//
//  NoteEditorView.swift
//  Milestone 19-21
//
//  Created by Anton Makeev on 09.04.2021.
//

import UIKit

class NoteEditorView: UIViewController, UITextViewDelegate {
    
    var vc: ViewController?
    var row: Int = 0
    var note: Note?
    
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet var textView: UITextView!
    
    override func viewDidLoad() {
        textView.delegate = self
        note = vc?.notes[row]
        textView.text = note?.body

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        textView.addDoneButton(title: "Done", target: self, selector: #selector(tapDone(sender:)))
        
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.shadowImage = UIImage()
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
    }
    
    @objc func tapDone(sender: Any) {
        view.endEditing(true)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = UIEdgeInsets.zero
        } else {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        textView.scrollIndicatorInsets = textView.contentInset
        
        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        note?.body = textView.text
    }

    override func viewWillDisappear(_ animated: Bool) {
        guard let note = note else { return }
        if !note.body.isEmpty {
            vc?.notes[row] = note
            vc?.tableView.reloadData()
        } else {
            vc?.removeNote(atRow: row)
        }
    }
    
    @IBAction func remove(_ sender: UIBarButtonItem) {
        guard let index = vc?.filteredNotes.firstIndex(where: { note?.uuid == $0.uuid }) else { return }
        vc?.removeNote(atRow: index)
        note = nil
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tappedShare(_ sender: UIBarButtonItem) {
        guard let note = note else { return }
        let vc = UIActivityViewController(activityItems: [note.body], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = sender
        present(vc, animated: true)
    }
    
    @IBAction func newNote(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
        vc?.createNote(sender)
    }
    
}
