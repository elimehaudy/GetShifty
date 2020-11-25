//
//  AppDelegate.swift
//  GetShifty
//
//  Created by Eli Mehaudy on 10/11/2020.
//

import UIKit
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        do {
         _ = try Realm()
        } catch {
            print("Error initializing new realm, \(error)")
        }
        print(Realm.Configuration.defaultConfiguration.fileURL)

        UITabBar.appearance().unselectedItemTintColor = #colorLiteral(red: 0.9572464824, green: 0.9103800654, blue: 0.8337891698, alpha: 1)
//        UITabBarItem.appearance().([NSAttributedString.Key.foregroundColor : UIColor.red], for: .normal)
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


}

