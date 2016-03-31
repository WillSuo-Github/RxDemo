//
//  RefreshExtension.swift
//  RxExample
//
//  Created by DianQK on 16/2/12.
//  Copyright © 2016年 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

private let _pulltoRefreshTag = 16754
private let _loadtoRefreshTag = 16755

private let _pullToRefreshDefaultHeight: CGFloat = 60
private let _loadToRefreshDefaultHeight: CGFloat = 60

extension UIScrollView {
    
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
            activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
            activityIndicatorView.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
            activityIndicatorView.bottomAnchor.constraintEqualToAnchor(topAnchor, constant: -10).active = true
        }
        
        return rx_contentOffset
            .filter { [unowned self] _ in !self.dragging } 
            .map { $0.y < -_pullToRefreshDefaultHeight }
            .distinctUntilChanged()
            .filter { $0 }
            .debounce(0.1, scheduler: MainScheduler.instance)
            .map { [unowned self] _ in
                activityIndicatorView.startAnimating()
                UIView.animateWithDuration(0.3) {
                    self.contentInset = UIEdgeInsets(top: 51, left: 0, bottom: 0, right: 0)
                }
        }
    }
    
    public func stopPullRefresh() {
        self.bounces = true
        (viewWithTag(_pulltoRefreshTag) as? UIActivityIndicatorView)?.stopAnimating()
        UIView.animateWithDuration(0.3) {
            self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    public var rx_pullRefreshAnimating: AnyObserver<Bool> {
        return UIBindingObserver(UIElement: self) { scrollView, active in
            if active {
                (scrollView.viewWithTag(_pulltoRefreshTag) as? UIActivityIndicatorView)?.startAnimating()
            } else {
                (scrollView.viewWithTag(_pulltoRefreshTag) as? UIActivityIndicatorView)?.stopAnimating()
                scrollView.bounces = true
                UIView.animateWithDuration(0.3) {
                    scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                }
            }
            }.asObserver()
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
            .map { _ in
                activityIndicatorView.startAnimating()
        }
    }
    
    public func stopLoadRefresh() {
        self.bounces = true
        (viewWithTag(_loadtoRefreshTag) as? UIActivityIndicatorView)?.stopAnimating()
    }
    
    var rx_reachedBottom: Observable<Void> {
        return rx_contentOffset
            .flatMap { [weak self] contentOffset -> Observable<Void> in
                guard let scrollView = self else {
                    return Observable.empty()
                }
                
                let visibleHeight = scrollView.frame.height - scrollView.contentInset.top - scrollView.contentInset.bottom
                let y = contentOffset.y + scrollView.contentInset.top
                let threshold = max(0.0, scrollView.contentSize.height - visibleHeight)
                
                return y > threshold ? Observable.just() : Observable.empty()
        }.throttle(0.1, scheduler: MainScheduler.instance)
    }
    
}

extension UIScrollView {
    
    public var rx_scrollEnabled: AnyObserver<Bool> {
        return UIBindingObserver(UIElement: self) { scrollView, enabled in
            scrollView.scrollEnabled = enabled
            }.asObserver()
    }
}