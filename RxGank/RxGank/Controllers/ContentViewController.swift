//
//  ContentViewController.swift
//  RxGank
//
//  Created by 宋宋 on 16/2/28.
//  Copyright © 2016年 DianQK. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources
import Kingfisher
import SnapKit
import SafariServices
import SwiftDate

typealias ContentSectionModel = AnimatableSectionModel<String, GankModel>

class ContentViewController: UITableViewController {
    
    @IBOutlet weak var headImageView: UIImageView!

    var day: NSDate?
    
    let disposeBag = DisposeBag()
    
    let sections = Variable([ContentSectionModel]())

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = nil
        tableView.delegate = nil
        tableView.sectionFooterHeight = 0
        
        GankProvider.request(.Day(day ?? NSDate.today()))
            .mapObject(DayModel)
            .subscribeNext { [unowned self] model in
                self.sections.value = model.results.map { ContentSectionModel(model: $0.0, items: $0.1) }
                if let imageStr = model.results["福利"]?.first?.url {
                    self.headImageView.kf_setImageWithURL(NSURL(string: imageStr)!)
                }
            }
            .addDisposableTo(disposeBag)
        
        let tvDataSource = RxTableViewSectionedReloadDataSource<ContentSectionModel>()
        tvDataSource.configureCell = { (tv, ip, i) in
            let cell = tv.dequeueReusableCellWithIdentifier("\(DetailTableViewCell.self)", forIndexPath: ip) as! DetailTableViewCell
            cell.descLabel.text = i.value.desc
            return cell
        }
        
        tvDataSource.titleForHeaderInSection = { section in
            return tvDataSource.sectionAtIndex(section).model
        }
        sections.asObservable()
            .bindTo(tableView.rx_itemsWithDataSource(tvDataSource)).addDisposableTo(disposeBag)
        
        tableView.rx_modelSelected(IdentitifiableValue<GankModel>).subscribeNext { [unowned self] model in
            let sfController = SFSafariViewController(URL: NSURL(string: model.value.url)!, entersReaderIfAvailable: true)
            sfController.view.tintColor = Configuration.Color.blackColor
            self.presentViewController(sfController, animated: true, completion: nil)
            
            }.addDisposableTo(disposeBag)
        
        tableView.rx_setDelegate(self)
        
    }

}

extension ContentViewController {
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 45
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cell = tableView.dequeueReusableCellWithIdentifier("\(DetailTableViewCell.self)") as! DetailTableViewCell
        cell.descLabel.text = sections.value[indexPath.section].items[indexPath.row].value.desc
        let titleHeight = cell.descLabel.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        return 5 + titleHeight + 5
    }
}