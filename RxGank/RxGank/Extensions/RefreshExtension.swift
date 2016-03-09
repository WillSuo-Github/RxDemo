//
//  RefreshExtension.swift
//  RxExample
//
//  Created by 宋宋 on 16/2/12.
//  Copyright © 2016年 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

private let _pulltoRefreshTag = 16754
private let _loadtoRefreshTag = 16755

private let _pullToRefreshDefaultHeight: CGFloat = 50
private let _loadToRefreshDefaultHeight: CGFloat = 50

extension UIScrollView {
    
    /// 下拉刷新，就先这样了 0.0
    
    public var rx_pullRefresh: Observable<Void> {
        let activityIndicatorView: UIActivityIndicatorView
        if let view = (viewWithTag(_pulltoRefreshTag) as? UIActivityIndicatorView) {
            activityIndicatorView = view
        } else {
            activityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: -_pullToRefreshDefaultHeight, width: frame.size.width, height: _pullToRefreshDefaultHeight))
            activityIndicatorView.tag = _pulltoRefreshTag
            activityIndicatorView.color = UIColor.blackColor()
            activityIndicatorView.hidesWhenStopped = false
            addSubview(activityIndicatorView)
        }
        
        return rx_contentOffset
            .filter { [unowned self] _ in !self.dragging }
            .map { $0.y < -50 }
            .distinctUntilChanged()
            .filter { $0 }
            .map { [unowned self] _ in
                activityIndicatorView.startAnimating()
                self.contentInset = UIEdgeInsets(top: 51, left: 0, bottom: 0, right: 0)
        }
    }
    
    public func stopPullRefresh() {
        self.bounces = true
        (viewWithTag(_pulltoRefreshTag) as? UIActivityIndicatorView)?.stopAnimating()
        UIView.animateWithDuration(0.3) {
            self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    public var rx_loadRefresh: Observable<Void> {
        let activityIndicatorView: UIActivityIndicatorView
        if let view = (viewWithTag(_pulltoRefreshTag) as? UIActivityIndicatorView) {
            activityIndicatorView = view
        } else {
            activityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: frame.size.height + _pullToRefreshDefaultHeight, width: frame.size.width, height: _loadToRefreshDefaultHeight))
            activityIndicatorView.tag = _loadtoRefreshTag
            activityIndicatorView.color = UIColor.blackColor()
            activityIndicatorView.hidesWhenStopped = false
            addSubview(activityIndicatorView)
        }
        return rx_contentOffset
            .map { [unowned self] in
                $0.y > self.contentSize.height - self.frame.size.height * 1.5
                && self.contentSize.height > self.frame.size.height * 1.5
            }
            .distinctUntilChanged()
            .filter { $0 }
            .map { _ in //[unowned self] _ in
                activityIndicatorView.startAnimating()
//                self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 51, right: 0)
        }
    }
    
    public func stopLoadRefresh() {
        self.bounces = true
        (viewWithTag(_loadtoRefreshTag) as? UIActivityIndicatorView)?.stopAnimating()
//        UIView.animateWithDuration(0.3) {
//            self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        }
    }
    
}