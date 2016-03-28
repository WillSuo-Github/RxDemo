//
//  UITableViewExtension.swift
//  RxGank
//
//  Created by DianQK on 16/3/28.
//  Copyright © 2016年 DianQK. All rights reserved.
//

import RxSwift
import RxCocoa

extension UITableView {
    public var rx_canEditRowAtIndexPath: ControlEvent<NSIndexPath> {
        let source = rx_dataSource.observe(#selector(UITableViewDataSource.tableView(_:canEditRowAtIndexPath:)))
            .filter { a in
                return UITableViewCellEditingStyle(rawValue: (a[1] as! NSNumber).integerValue) == .Insert
            }
            .map { a in
                return (a[2] as! NSIndexPath)
        }
        
        return ControlEvent(events: source)
    }
}
