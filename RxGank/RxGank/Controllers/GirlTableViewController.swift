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

enum Action {
    case Refresh
    case LoadMore(Int)
}

typealias LoadMore = Bool

typealias GirlSectionModel = AnimatableSectionModel<String, GankModel>

class GirlTableViewController: UITableViewController {
    
    let disposeBag = DisposeBag()
    
    let sections = Variable([GirlSectionModel]())

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = nil
        tableView.delegate = nil
        /// 加载 + 下拉刷新 + 加载更多 一种供参考的写法~
        let command: [Observable<LoadMore>] = [
            Observable.just(false), // 可以改成 enum 判断是刷新还是加载更多
            tableView.rx_pullRefresh.map { _ in false },
            tableView.rx_loadRefresh.map { _ in true }
        ]
        
        command.toObservable().merge()
            .scan(1) { $1 ? $0 + 1 : 1 } // 用 scan 记录加载 page
            .flatMap { page in
                GankProvider.request(.Category(.福利, 5, page))
                    .mapArray(GankModel).map { (page, $0) }
            }
            .subscribeNext { [unowned self] page, models in // use scan
                if page == 1 {
                    self.sections.value = [GirlSectionModel(model: "", items: models)]
                } else {
                    self.sections.value.append(GirlSectionModel(model: "", items: models ))
                }
                self.tableView.stopPullRefresh()
                self.tableView.stopLoadRefresh() // ==
            }.addDisposableTo(disposeBag)
        
        let tvDataSource = RxTableViewSectionedReloadDataSource<GirlSectionModel>()
        tvDataSource.configureCell = { (tv, ip, i) in
            let cell = tv.dequeueReusableCellWithIdentifier("\(GirlTableViewCell.self)") as! GirlTableViewCell
            cell.contentImageView.kf_setImageWithURL(NSURL(string: i.value.url)!)
            return cell
        }
        
        sections.asObservable()
            .bindTo(tableView.rx_itemsWithDataSource(tvDataSource))
            .addDisposableTo(disposeBag)
        
        tableView.rx_modelSelected(IdentitifiableValue<GankModel>)
            .subscribeNext { [unowned self] model in
                let contentViewController = UIStoryboard(name: .Main).instantiateViewControllerWithClass(ContentViewController)
                contentViewController.day = model.value.publishedAt.toDate(.ISO8601Format(.Extended))
                self.navigationController?.pushViewController(contentViewController, animated: true)
            }
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

