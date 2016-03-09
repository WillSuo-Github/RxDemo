//
//  AppDelegate.swift
//  RxGank
//
//  Created by 宋宋 on 16/2/28.
//  Copyright © 2016年 DianQK. All rights reserved.
//

import UIKit
import TransitionTreasury

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        if let tabBarVC = window?.rootViewController as? UITabBarController {
            tabBarVC.tabBar.hidden = true
            tabBarVC.tr_transitionDelegate = TRTabBarTransitionDelegate(method: GankTransition.Slide)
        }
        let seeGirl = UIApplicationShortcutItem(type: "Meizi", localizedTitle: "看妹子", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .CapturePhoto), userInfo: nil)
        let seeTech = UIApplicationShortcutItem(type: "Tech", localizedTitle: "看技术", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .Bookmark), userInfo: nil)
        
        application.shortcutItems = [seeGirl, seeTech]
        
        configureNavgationBar()
        
        return true
    }
    
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        if shortcutItem.type == "Meizi" {
            if let tabBarVC = window?.rootViewController as? UITabBarController {
                tabBarVC.selectedIndex = 0
            }
        } else if shortcutItem.type == "Tech" {
            if let tabBarVC = window?.rootViewController as? UITabBarController {
                tabBarVC.selectedIndex = 1
            }
        }
        completionHandler(true)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

extension AppDelegate {
    func configureNavgationBar() {
        let navBar = UINavigationBar.appearance()
        navBar.shadowImage = UIImage()
        navBar.barTintColor = UIColor.whiteColor()
        navBar.tintColor = Configuration.Color.blackColor
        navBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
    }
}