//
//  TechViewController.swift
//  RxGank
//
//  Created by 宋宋 on 16/3/6.
//  Copyright © 2016年 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Kingfisher
import Moya
import SwiftDate
import SafariServices

typealias TechSectionModel = AnimatableSectionModel<String, GankModel>

class TechViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    let sections = Variable([TechSectionModel]())
    
    let disposeBag = DisposeBag()
    
    var currentPage: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// 添加滑动切换手势
        view.addGestureRecognizer(configureSlideGesture())
        
        func configureCategory(rawCategory: Int) -> GankCategory {
            switch rawCategory {
            case 0: return GankCategory.iOS
            case 1: return GankCategory.Android
            case 2: return GankCategory.前端
            default: fatalError()
            }
        }
        
        /// 切换分类
        segmentedControl.rx_value
            .map { configureCategory($0) }
            .flatMapLatest { GankProvider.request(.Category($0, 15, 1)) }
            .retry(2)
            .mapArray(GankModel)
            .subscribeNext { [unowned self] in
                self.sections.value = [TechSectionModel(model: "", items: $0)]
            }
            .addDisposableTo(disposeBag)
        
        /// 下拉刷新
        tableView.rx_pullRefresh
            .map { [unowned self] in
                self.currentPage = 1
                return configureCategory(self.segmentedControl.selectedSegmentIndex)
            }
            .flatMapLatest { GankProvider.request(.Category($0, 15, 1)) }
            .retry(2).mapArray(GankModel)
            .bindNext { [unowned self] in
                self.tableView.stopPullRefresh()
                self.sections.value = [TechSectionModel(model: "", items: $0)]
            }
            .addDisposableTo(disposeBag)
        
        /// 下拉加载更多
        tableView.rx_loadRefresh
            .map { [unowned self] () -> (category: GankCategory, page: Int)in
                self.currentPage += 1
                return (category: configureCategory(self.segmentedControl.selectedSegmentIndex)
                    , page: self.currentPage)
            }
            .flatMapLatest { GankProvider.request(.Category($0.category, 15, $0.page)) }.retry(2).mapArray(GankModel).bindNext { [unowned self] in
                self.tableView.stopLoadRefresh()
                self.sections.value.append(TechSectionModel(model: "", items: $0))
            }
            .addDisposableTo(disposeBag)
        
        let tvDataSource = RxTableViewSectionedReloadDataSource<GirlSectionModel>()
        tvDataSource.configureCell = { (tv, ip, i) in
            let cell = tv.dequeueReusableCellWithIdentifier("\(TechTableViewCell.self)", forIndexPath: ip) as! TechTableViewCell
            cell.contentTitleLabel.text = i.value.desc
            cell.contentTimeLabel.text = i.value.publishedAt.toDate(.ISO8601Format(.Extended))?.toString() ?? "unknown"
            return cell
        }
        
        sections.asObservable()
            .bindTo(tableView.rx_itemsWithDataSource(tvDataSource))
            .addDisposableTo(disposeBag)
        
        tableView.rx_modelSelected(IdentitifiableValue<GankModel>)
            .subscribeNext { [unowned self] model in
                let sfController = SFSafariViewController(URL: NSURL(string: model.value.url)!, entersReaderIfAvailable: true)
                sfController.view.tintColor = Configuration.Color.blackColor
                self.presentViewController(sfController, animated: true, completion: nil)
                }
            .addDisposableTo(disposeBag)
        
        tableView.rx_setDelegate(self)
        
    }

}

// MARK: - 设置 TableViewCell 高度

extension TechViewController : UIScrollViewDelegate {
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cell = tableView.dequeueReusableCellWithIdentifier("\(TechTableViewCell.self)") as! TechTableViewCell
        cell.contentTitleLabel.text = sections.value[indexPath.section].items[indexPath.row].value.desc
        let titleHeight = cell.contentTitleLabel.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        return 5 + titleHeight + 5 + 14 + 5
    }
}

// MARK: - TabBar 滑动切换 GestureRecognizerDelegate

extension TechViewController: UIGestureRecognizerDelegate {
    
    func configureSlideGesture() -> UIPanGestureRecognizer {
        let gesture = UIPanGestureRecognizer()
        
        gesture.delegate = self
        gesture.maximumNumberOfTouches = 1
        gesture.rx_event
            .filter { $0.state == .Began }
            .subscribeNext { [unowned self] in
                self.tabBarController?.tr_selected(0, gesture: $0)
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