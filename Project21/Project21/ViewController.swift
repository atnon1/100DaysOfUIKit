//
//  ViewController.swift
//  Project21
//
//  Created by Anton Makeev on 08.04.2021.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(tapSchedule))
    }

    @objc func registerLocal() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.badge, .sound, .alert]) {
            (granted, error) in
            if granted {
                print ("Yoy")
            } else {
                print("auch")
            }
        }
        
    }
    
    @objc func tapSchedule() {
        scheduleLocal()
    }
    
    func scheduleLocal(interval: TimeInterval = 5) {
        registerCategories()
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        let dateComponents = DateComponents(hour: 18, minute: 5)
        let content = UNMutableNotificationContent()
        content.title = "My notification"
        content.body = "Here is a body"
        content.userInfo = ["CustomData" : "blahblah"]
        content.categoryIdentifier = "alarm"
        content.sound = UNNotificationSound.default
        //let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        let show = UNNotificationAction(identifier: "show", title: "Tell me more..", options: .foreground)
        let showAnother = UNNotificationAction(identifier: "showAnother", title: "Tell me another..", options: .foreground)
        let later = UNNotificationAction(identifier: "later", title: "Remind me later", options: .authenticationRequired)
        let showCategory = UNNotificationCategory(identifier: "alarm", actions: [show, showAnother, later], intentIdentifiers: [])
        center.setNotificationCategories([showCategory])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo["CustomData"]
        if let customData = userInfo as? String {
                print(customData)
            let alert = UIAlertController(title: "You came from notification", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                print("default")
            case "show":
                alert.message = "I am showing you"
                present(alert, animated: true)
            case "showAnother":
                alert.message = "I am showing you another"
                present(alert, animated: true)
            case "later":
                scheduleLocal(interval: 10)
            default:
                break
            }
        }
        completionHandler()
    }
}

