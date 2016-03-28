//
//  ActivityIndicatorView.swift
//  RxGank
//
//  Created by 宋宋 on 16/3/28.
//  Copyright © 2016年 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


public class ActivityIndicatorView: UIView {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var rx_animating: AnyObserver<Bool> {
        return activityIndicator.rx_animating
    }
    
}
