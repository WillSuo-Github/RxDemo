//
//  UIViewControllerExtension.swift
//  RxGank
//
//  Created by 宋宋 on 16/3/31.
//  Copyright © 2016年 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension UIViewController {
    public var rx_title: AnyObserver<String?> {
        return UIBindingObserver(UIElement: self) { viewController, title in
            viewController.title = title
            }.asObserver()
    }
}
