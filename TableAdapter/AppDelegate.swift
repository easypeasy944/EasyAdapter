//
//  AppDelegate.swift
//  TableAdapter
//
//  Created by Aynur Galiev on 6.ноября.2016.
//  Copyright © 2016 Aynur Galiev. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = {
        let keyWindow = UIWindow()
        keyWindow.frame = UIScreen.main.bounds
        keyWindow.makeKeyAndVisible()
        return keyWindow
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if UserDefaults.standard.bool(forKey: "isTest") {
            self.window?.rootViewController = UIViewController()
        }
        
        return true
    }
}

