//
//  AppDelegate.swift
//  RxGank
//
//  Created by DianQK on 16/2/28.
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

}

extension AppDelegate {
    func configureNavgationBar() {
        let navBar = UINavigationBar.appearance()
        navBar.shadowImage = UIImage()
        navBar.barTintColor = UIColor.whiteColor()
        navBar.tintColor = Config.Color.blackColor
        navBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
    }
}