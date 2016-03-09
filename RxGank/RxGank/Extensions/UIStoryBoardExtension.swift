//
//  UIStoryBoardExtension.swift
//  RxGanHuo
//
//  Created by 宋宋 on 16/2/24.
//  Copyright © 2016年 DianQK. All rights reserved.
//

import UIKit

public enum StoryboardName: String {
    case Main = "Main"
    case Setting = "Setting"
}

public extension UIStoryboard {
    public convenience init(name: StoryboardName, bundle storyboardBundleOrNil: NSBundle? = nil) {
        self.init(name: name.rawValue, bundle: storyboardBundleOrNil)
    }
    
    public func instantiateViewControllerWithClass<T: UIViewController>(type: T.Type) -> T {
        return instantiateViewControllerWithIdentifier("\(T.self)") as! T
    }
}
