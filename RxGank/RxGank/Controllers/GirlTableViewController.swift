//
//  GirlTableViewController.swift
//  RxGank
//
//  Created by DianQK on 16/2/28.
//  Copyright © 2016年 DianQK. All rights reserved.
//

import RxSwift
import RxCocoa
import Kingfisher
import SwiftDate
import NSObject_Rx

class GirlTableViewController: UITableViewController {
    
    var viewModel: GirlViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = nil
        tableView.delegate = nil
        
        let loadActivityIndicatorView = tableView.tableFooterView as! ActivityIndicatorView
        
        viewModel = GirlViewModel(
            input: (
                refreshTriger: tableView.rx_pullRefresh.asObservable(),
                loadMoreTriger: tableView.rx_reachedBottom.asObservable())
        )
        
        viewModel.refreshing.asObservable()
            .bindTo(tableView.rx_pullRefreshAnimating)
            .addDisposableTo(rx_disposeBag)
        
        viewModel.loading.asObservable()
            .bindTo(loadActivityIndicatorView.rx_animating)
            .addDisposableTo(rx_disposeBag)
        
        viewModel.elements.asObservable()
            .bindTo(tableView.rx_itemsWithCellIdentifier("\(GirlTableViewCell.self)", cellType: GirlTableViewCell.self)) { _, v, cell in
                cell.contentImageView.kf_setImageWithURL(NSURL(string: v.url)!)
            }
            .addDisposableTo(rx_disposeBag)
        
        viewModel.elements.asObservable().map { !$0.isEmpty }
            .bindTo(tableView.rx_scrollEnabled)
            .addDisposableTo(rx_disposeBag)
        
        tableView.rx_modelSelected(GankModel)
            .subscribeNext { [unowned self] model in
                let contentViewController = UIStoryboard(name: .Main).instantiateViewControllerWithClass(ContentViewController)
                contentViewController.day = model.publishedAt.toDate(.ISO8601Format(.Extended))
                self.navigationController?.pushViewController(contentViewController, animated: true)
            }
            .addDisposableTo(rx_disposeBag)
        
        Observable.just(())
            .bindTo(viewModel.loadTriger)
            .addDisposableTo(rx_disposeBag)
        
        view.addGestureRecognizer(configureEdgePanGesture(.Right, selected: 1))
    }

}



