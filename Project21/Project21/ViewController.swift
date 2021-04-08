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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleLocal))
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
    
    
    @objc func scheduleLocal() {
        registerCategories()
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        let dateComponents = DateComponents(hour: 18, minute: 5)
        let content = UNMutableNotificationContent()
        content.title = "My notification"
        content.body = "Here is a body"
        content.userInfo = ["CustomData" : "blahblah"]
        content.categoryIdentifier = "alert"
        content.sound = UNNotificationSound.default
        //let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        let show = UNNotificationAction(identifier: "show", title: "Tell me more..", options: .foreground)
        let category = UNNotificationCategory(identifier: "alert", actions: [show], intentIdentifiers: [])
        center.setNotificationCategories([category])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo["CustomData"]
        if let customData = userInfo as? String {
                print(customData)
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                print("default")
            case "show":
                print("show more information")
            default:
                break
            }
        }
        completionHandler()
    }
}

