//
//  AppDelegate.swift
//  Travel Time
//
//  Created by Daniel Plescia on 2/28/17.
//  Copyright © 2017 Daniel Plescia. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    UIApplication.shared.statusBarStyle = .default
    
    let navigationBarAppearance = UINavigationBar.appearance()
    
    navigationBarAppearance.tintColor = UIColor.white
    navigationBarAppearance.barTintColor = UIColor(red: 0.09, green: 0.93, blue: 0.345, alpha: 1)
    navigationBarAppearance.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white,NSFontAttributeName:UIFont.systemFont(ofSize: 23)]
    fillUserDefaults()
    
    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler:
        @escaping (Bool) -> Void) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var vc = UIViewController()
        if shortcutItem.type == "com.danielplescia.traveltime.Travel-Time.Home" {
            vc = storyboard.instantiateViewController(withIdentifier: "HomeNC")
        } else if shortcutItem.type == "com.danielplescia.traveltime.Travel-Time.Work" {
            vc = storyboard.instantiateViewController(withIdentifier: "WorkNC")
        }
        else {
            vc = storyboard.instantiateViewController(withIdentifier: "CustomNC")
        }
        window?.rootViewController?.present(vc, animated: false, completion: nil)
    }

    func fillUserDefaults() {
        if UserDefaults.standard.value(forKey: "homeAddress") == nil {
            UserDefaults.standard.setValue([""], forKey: "homeAddress")
        }
        if UserDefaults.standard.value(forKey: "workAddress") == nil {
            UserDefaults.standard.setValue([""], forKey: "workAddress")
        }
        if UserDefaults.standard.value(forKey: "customAddress1") == nil {
            UserDefaults.standard.setValue([""], forKey: "customAddress1")
        }
        if UserDefaults.standard.value(forKey: "customAddress2") == nil {
            UserDefaults.standard.setValue([""], forKey: "customAddress2")
        }
        if UserDefaults.standard.value(forKey: "customAddress3") == nil {
            UserDefaults.standard.setValue([""], forKey: "customAddress3")
        }
        if UserDefaults.standard.value(forKey: "distanceUnits") == nil {
            UserDefaults.standard.setValue("imperial", forKey: "distanceUnits")
        }
    }

}

