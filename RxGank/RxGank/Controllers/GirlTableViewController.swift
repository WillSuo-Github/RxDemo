//
//  GirlTableViewController.swift
//  RxGank
//
//  Created by 宋宋 on 16/2/28.
//  Copyright © 2016年 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Kingfisher
import SwiftDate

typealias GirlSectionModel = AnimatableSectionModel<String, GankModel>

class GirlTableViewController: UITableViewController {
    
    let disposeBag = DisposeBag()
    
    let sections = Variable([GirlSectionModel]())
    
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
            .addDisposableTo(disposeBag)
        
        viewModel.loading.asObservable()
            .bindTo(loadActivityIndicatorView.rx_animating)
            .addDisposableTo(disposeBag)
        
        viewModel.elements.asObservable()
            .bindTo(tableView.rx_itemsWithCellIdentifier("\(GirlTableViewCell.self)", cellType: GirlTableViewCell.self)) { _, v, cell in
                cell.contentImageView.kf_setImageWithURL(NSURL(string: v.url)!)
            }
            .addDisposableTo(disposeBag)
        
        tableView.rx_modelSelected(GankModel)
            .subscribeNext { [unowned self] model in
                let contentViewController = UIStoryboard(name: .Main).instantiateViewControllerWithClass(ContentViewController)
                contentViewController.day = model.publishedAt.toDate(.ISO8601Format(.Extended))
                self.navigationController?.pushViewController(contentViewController, animated: true)
            }
            .addDisposableTo(disposeBag)
        
        Observable.just(())
            .bindTo(viewModel.loadTriger)
            .addDisposableTo(disposeBag)
        
        view.addGestureRecognizer(configureSlideGesture())
    }

}

extension GirlTableViewController: UIGestureRecognizerDelegate {
    
    func configureSlideGesture() -> UIPanGestureRecognizer {
        let gesture = UIPanGestureRecognizer()
        
        gesture.delegate = self
        gesture.maximumNumberOfTouches = 1
        gesture.rx_event
            .filter { $0.state == .Began }
            .subscribeNext { [unowned self] in
                self.tabBarController?.tr_selected(1, gesture: $0)
            }
            .addDisposableTo(disposeBag)
        return gesture
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            return gestureRecognizer.translationInView(gestureRecognizer.view).x != 0
        }
        return false
    }
}

