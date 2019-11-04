//
//  AppDelegate.swift
//  LsqCalendar
//
//  Created by 罗石清 on 2019/11/1.
//  Copyright © 2019 HunanChangxingTrafficWisdom. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let nav = UINavigationController(rootViewController: ViewController())
        
        self.window?.rootViewController = nav
        
        self.window?.makeKeyAndVisible()
        
        return true
    }


}

