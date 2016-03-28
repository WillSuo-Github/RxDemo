//
//  UIViewControllerExtension.swift
//  RxGank
//
//  Created by DianQK on 16/3/28.
//  Copyright © 2016年 DianQK. All rights reserved.
//

import RxSwift
import RxCocoa

extension UIViewController {
    
    func configureEdgePanGesture(edges: UIRectEdge, selected: Int) -> UIScreenEdgePanGestureRecognizer {
        let gesture = UIScreenEdgePanGestureRecognizer()
        gesture.edges = edges
        gesture.rx_event
            .filter { $0.state == .Began }
            .subscribeNext { [unowned self] in
                self.tabBarController?.tr_selected(selected, gesture: $0)
            }
            .addDisposableTo(rx_disposeBag)
        return gesture
    }
    
}