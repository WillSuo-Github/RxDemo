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
import SafariServices

typealias TechSectionModel = AnimatableSectionModel<String, GankModel>

class TechViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    let sections = Variable([TechSectionModel]())
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addGestureRecognizer(configureSlideGesture())
        
        segmentedControl.rx_value.flatMapLatest { value -> Observable<Response> in
            switch value {
            case 0: return GankProvider.request(.Category(.iOS, 10, 1))
            case 1: return GankProvider.request(.Category(.Android, 10, 1))
            case 2: return GankProvider.request(.Category(.前端, 10, 1))
            default: fatalError()
            }
            
            }.mapArray(GankModel).subscribeNext { [unowned self] in
                print($0)
                self.sections.value = [TechSectionModel(model: "", items: $0)]
        }.addDisposableTo(disposeBag)
        
        let tvDataSource = RxTableViewSectionedReloadDataSource<GirlSectionModel>()
        tvDataSource.configureCell = { (tv, ip, i) in
            let cell = tv.dequeueReusableCellWithIdentifier("TechCell", forIndexPath: ip)
            cell.textLabel?.text = i.value.desc
            cell.detailTextLabel?.text = i.value.publishedAt
            return cell
        }
        
        sections.asObservable()
            .bindTo(tableView.rx_itemsWithDataSource(tvDataSource)).addDisposableTo(disposeBag)
        
        tableView.rx_modelSelected(IdentitifiableValue<GankModel>).subscribeNext { [unowned self] model in
            let sfController = SFSafariViewController(URL: NSURL(string: model.value.url)!, entersReaderIfAvailable: true)
            sfController.view.tintColor = Configuration.Color.blackColor
            self.presentViewController(sfController, animated: true, completion: nil)
            
            }.addDisposableTo(disposeBag)
        
        tableView.addGestureRecognizer(configureSlideGesture())
        
    }

}

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