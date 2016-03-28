//
//  TechViewController.swift
//  RxGank
//
//  Created by DianQK on 16/3/6.
//  Copyright © 2016年 DianQK. All rights reserved.
//

import RxSwift
import RxCocoa
import Kingfisher
import Moya
import SwiftDate
import SafariServices
import NSObject_Rx

class TechViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: TechViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 56.5
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let loadActivityIndicatorView = tableView.tableFooterView as! ActivityIndicatorView
        
        func configureCategory(rawCategory: Int) -> GankCategory {
            switch rawCategory {
            case 0: return .iOS
            case 1: return .Android
            case 2: return .前端
            default: fatalError()
            }
        }
        
        viewModel = TechViewModel(
            input: (
                refreshTriger: tableView.rx_pullRefresh.asObservable(),
                loadMoreTriger: tableView.rx_reachedBottom.asObservable(),
                categoryChangeTriger: segmentedControl.rx_value.map { configureCategory($0) }.asObservable())
        )
        
        viewModel.refreshing.asObservable()
            .bindTo(tableView.rx_pullRefreshAnimating)
            .addDisposableTo(rx_disposeBag)
        
        viewModel.loading.asObservable()
            .bindTo(loadActivityIndicatorView.rx_animating)
            .addDisposableTo(rx_disposeBag)
        
        viewModel.elements.asObservable()
            .bindTo(tableView.rx_itemsWithCellIdentifier("\(TechTableViewCell.self)", cellType: TechTableViewCell.self)) { _, v, cell in
                cell.contentTitleLabel.text = v.desc
                cell.contentTimeLabel.text = v.publishedAt.toDate(.ISO8601Format(.Extended))?.toString() ?? "unknown"
            }
            .addDisposableTo(rx_disposeBag)
        
        viewModel.elements.asObservable().map { !$0.isEmpty }
            .bindTo(tableView.rx_scrollEnabled)
            .addDisposableTo(rx_disposeBag)
        
        tableView.rx_modelSelected(GankModel)
            .subscribeNext { [unowned self] model in
                let sfController = SFSafariViewController(URL: NSURL(string: model.url)!, entersReaderIfAvailable: true)
                sfController.view.tintColor = Config.Color.blackColor
                self.presentViewController(sfController, animated: true, completion: nil)
                }
            .addDisposableTo(rx_disposeBag)
        
        view.addGestureRecognizer(configureEdgePanGesture(.Left, selected: 0))
        
    }

}