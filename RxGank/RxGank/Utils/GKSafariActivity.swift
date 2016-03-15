//
//  GKSafariActivity.swift
//  RxGank
//
//  Created by 宋宋 on 16/3/15.
//  Copyright © 2016年 DianQK. All rights reserved.
//

import UIKit

class GKSafariActivity: UIActivity {
    
    private var url: NSURL?
    
    override func activityType() -> String? {
        return "\(GKSafariActivity.self)"
    }
    
    override func activityTitle() -> String? {
        return "在 Safari 中打开"
    }
    
    override func activityImage() -> UIImage? {
        return UIImage(named: "safari")
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        for activityItem in activityItems {
            if let _  = activityItem as? NSURL {
                return true
            }
        }
        
        return false
    }
    
    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        for activityItem in activityItems {
            if let activityItem = activityItem as? NSURL {
                url = activityItem
            }
        }
    }
    
    override func performActivity() {
        let completed = UIApplication.sharedApplication().openURL(url!)
        activityDidFinish(completed)
    }
    
}
