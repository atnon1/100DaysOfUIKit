//
//  ViewController.swift
//  Project28
//
//  Created by Anton Makeev on 24.04.2021.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var secret: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Nothing to see here"
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)
        //navigationItem.setRightBarButton(nil, animated: true)
    }

    @IBAction func authenticateTapped(_ sender: UIButton) {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, error in
                DispatchQueue.main.async {
                    if success {
                        self?.unlockSecret()
                        if !KeychainWrapper.standard.hasValue(forKey: "Password") {
                            self?.askPasswordSet()
                        }
                    } else {
                        let ac = UIAlertController(title: "Authentication failed", message: "You could not be verified; please try again", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default){ [weak self] _ in
                            self?.askPassword()
                        })
                        self?.present(ac, animated: true)
                    }
                }
            }
        } else {
            let ac = UIAlertController(title: "Biometry unavailable", message: "Your device is not configured for biometrical authentication", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.askPassword()
            })
            present(ac, animated: true)
        }
    }
    
    @objc func adjustKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, to: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            secret.contentInset = .zero
        } else {
            secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        secret.scrollIndicatorInsets = secret.contentInset
        
        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
    }
    
    func unlockSecret() {
        secret.isHidden = false
        title = "Secret stuff!"
        secret.text = KeychainWrapper.standard.string(forKey: "SecretMessage") ?? ""
        let rightButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveSecretMessage))
        navigationItem.setRightBarButton(rightButtonItem, animated: true)
    }
    
    @objc func saveSecretMessage() {
        guard secret.isHidden == false else { return }
        
        KeychainWrapper.standard.set(secret.text, forKey: "SecretMessage")
        secret.resignFirstResponder()
        secret.isHidden = true
        title = "Nothing to see here"
        navigationItem.setRightBarButton(nil, animated: true)
    }
    
    func askPasswordSet() {
        guard secret.isHidden == false else { return }
        
        let ac = UIAlertController(title: "Set password", message: "Password is needed in case biometry is unavaliable", preferredStyle: .alert)
        ac.addTextField { textField in
            textField.delegate = self
            textField.isSecureTextEntry = true
            textField.placeholder = "Enter password"
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { _ in
                if (ac.textFields![0].text!.count > 0) && (ac.textFields![0] == ac.textFields![1]) {
                    ac.actions[0].isEnabled = true
                } else {
                    ac.actions[0].isEnabled = false
                }
            }
        }
        ac.addTextField { textField in
            textField.delegate = self
            textField.isSecureTextEntry = true
            textField.placeholder = "Repeat password"
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { _ in
                if (ac.textFields![0].text!.count > 0) && (ac.textFields![0].text == ac.textFields![1].text) {
                    ac.actions[0].isEnabled = true
                } else {
                    ac.actions[0].isEnabled = false
                }
            }
        }
        ac.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            if let password = ac.textFields?[0].text {
                KeychainWrapper.standard.set(password, forKey: "Password")
            }
        })
        ac.actions[0].isEnabled = false
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 8
        let currentString: NSString = (textField.text ?? "") as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    func askPassword() {
        let ac = UIAlertController(title: "Enter password", message: nil, preferredStyle: .alert)
        ac.addTextField { textField in
                textField.isSecureTextEntry = true
        }
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let keychainPassword = KeychainWrapper.standard.string(forKey: "Password") else { return }
            let password = ac.textFields![0].text ?? ""
            if password == keychainPassword {
                self?.unlockSecret()
            } else {
                let wrongAlert = UIAlertController(title: "Wrong Password", message: "Try again", preferredStyle: .alert)
                wrongAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in self?.askPassword() })
                self?.present(wrongAlert, animated: true)
            }
        }
        )
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
}

