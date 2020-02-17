//
//  AppDelegate.swift
//  foodOrderApp
//
//  Created by Sujata on 17/12/19.
//  Copyright © 2019 Sujata. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        NetworkCheck.sharedInstance.startMonitoring()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("gotInternetConnection"), object: nil, queue: nil) { notification in
            
            DispatchQueue.main.async {
                LocationManager.shared.start()
            }
        }
    
        //LocationManager.shared.start()
        
        UITabBar.appearance().barTintColor = #colorLiteral(red: 0.6941176471, green: 0.537254902, blue: 0.5568627451, alpha: 1)
        UITabBar.appearance().unselectedItemTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        UITabBar.appearance().tintColor = #colorLiteral(red: 0.737254902, green: 0.1921568627, blue: 0.08235294118, alpha: 1)
        return true
    }

//    func applicationDidBecomeActive(_ application: UIApplication)
//    {
//        print("applicationDidBecomeActive")
//    }
    
    func applicationWillTerminate(_ application: UIApplication)
    {
        LocationManager.shared.stop()
        NetworkCheck.sharedInstance.stopMonitoring()
    }
}

