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
import MobileCoreServices

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
                    self.headImageView.kf_setImageWithURL(NSURL(string: imageStr)!, placeholderImage: nil, optionsInfo: nil){ _ in
                        self.navigationItem.rightBarButtonItem?.enabled = true
                    }
                }
            }
            .addDisposableTo(disposeBag)
        
        let tvDataSource = RxTableViewSectionedReloadDataSource<ContentSectionModel>()
        tvDataSource.configureCell = { (_, tv, ip, i) in
            let cell = tv.dequeueReusableCellWithIdentifier("\(DetailTableViewCell.self)", forIndexPath: ip) as! DetailTableViewCell
            cell.descLabel.text = i.value.desc
            return cell
        }
        
        tvDataSource.titleForHeaderInSection = { $0.0.sectionAtIndex($0.1).model }
        
        sections.asObservable()
            .bindTo(tableView.rx_itemsWithDataSource(tvDataSource))
            .addDisposableTo(disposeBag)
        
        tableView.rx_modelSelected(IdentitifiableValue<GankModel>).subscribeNext { [unowned self] model in
            let sfController = SFSafariViewController(URL: NSURL(string: model.value.url)!, entersReaderIfAvailable: true)
            sfController.view.tintColor = Configuration.Color.blackColor
            self.presentViewController(sfController, animated: true, completion: nil)
            
            }.addDisposableTo(disposeBag)
        
        tableView.rx_setDelegate(self)

        navigationItem.rightBarButtonItem?.rx_tap
            .subscribeNext { [unowned self] in
                let shareURL = NSURL(string: "http://gank.io/\(self.day!.toString(.Custom("yyyy/MM/dd"))!)")!
                let itemProvider = NSItemProvider()
                itemProvider.registerItemForTypeIdentifier(kUTTypeURL as String) {
                    completionHandler, expectedClass, options in
                    completionHandler(shareURL, nil)
                }
                itemProvider.previewImageHandler = { completionHandler, expectedClass, options in
                    completionHandler(self.headImageView.image, nil)
                }
                // 个人认为这里的 activityItems 应该强制换成 NSItemProvider ，然后我们的 UIActivity 也可以进行统一的检测了~ 这里不统一会很麻烦 ==
                let vc = UIActivityViewController(activityItems: [self.headImageView.image!, shareURL],
                    applicationActivities: [GKSafariActivity()])
                self.presentViewController(vc, animated: true, completion: nil)
        }.addDisposableTo(disposeBag)
        
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