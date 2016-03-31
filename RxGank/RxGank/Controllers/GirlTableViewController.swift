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

class GirlTableViewController: UITableViewController, TabBarTransitionType {
    
    var viewModel: GirlViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = nil
        tableView.delegate = nil
        
        let loadActivityIndicatorView = tableView.tableFooterView as! ActivityIndicatorView
        
        viewModel = GirlViewModel(
            input: (
                refreshTriger: tableView.rx_pullRefresh.asDriver(onErrorJustReturn: ()),
                loadMoreTriger: tableView.rx_reachedBottom.asDriver(onErrorJustReturn: ()).startWith(()))
        )
        
        viewModel.refreshing.asDriver()
            .drive(tableView.rx_pullRefreshAnimating)
            .addDisposableTo(rx_disposeBag)
        
        viewModel.loading.asDriver()
            .drive(loadActivityIndicatorView.rx_animating)
            .addDisposableTo(rx_disposeBag)
        
        viewModel.elements.asDriver()
            .drive(tableView.rx_itemsWithCellIdentifier("\(GirlTableViewCell.self)", cellType: GirlTableViewCell.self)) { _, v, cell in
                cell.contentImageView.kf_setImageWithURL(NSURL(string: v.url)!)
            }
            .addDisposableTo(rx_disposeBag)
        
        viewModel.elements.asDriver()
            .map { $0.isNotEmpty }
            .drive(tableView.rx_scrollEnabled)
            .addDisposableTo(rx_disposeBag)
        
        tableView.rx_modelSelected(GankModel)
            .subscribeNext { [unowned self] model in
                let contentViewController = UIStoryboard(name: .Main).instantiateViewControllerWithClass(ContentViewController)
                contentViewController.day.value = model.publishedAt.toDate(.ISO8601Format(.Extended))!
                self.navigationController?.pushViewController(contentViewController, animated: true)
            }
            .addDisposableTo(rx_disposeBag)
        
        view.addGestureRecognizer(configureEdgePanGesture(.Right, selected: 1))
    }

}
