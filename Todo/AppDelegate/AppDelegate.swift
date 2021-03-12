//
//  AppDelegate.swift
//  Todo
//
//  Created by 유준상 on 2021/02/09.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var index: Int = 0

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge]) { (authorized, error) in
            if !authorized {
                print("App is useless becase you did not allow notification")
            }
        }

        
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func showNotification(date: Date, title: String) {
        print("AppDelegate - showNotification() called")
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .medium
        dateformatter.timeStyle = .medium
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = dateformatter.string(from: date)
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "category"
        
        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute],from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        

        let request = UNNotificationRequest(identifier: "todoNotification\(index)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("error : \(error.localizedDescription)")
            }
        }
        index = index + 1
    }
}

