//
//  ContentViewController.swift
//  RxGank
//
//  Created by DianQK on 16/2/28.
//  Copyright © 2016年 DianQK. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources
import SafariServices
import SwiftDate
import MobileCoreServices

class ContentViewController: UITableViewController {
    
    @IBOutlet weak var headImageView: UIImageView!
    
    @IBOutlet weak var imageActivityIndicatorView: UIActivityIndicatorView!

    var day = Variable(NSDate())
    
    var viewModel: ContentViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = nil
        tableView.delegate = nil
        tableView.sectionFooterHeight = 0
        
        tableView.estimatedRowHeight = 45
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let tvDataSource = RxTableViewSectionedReloadDataSource<ContentSectionModel>()
        tvDataSource.configureCell = { (_, tv, ip, i) in
            let cell = tv.dequeueReusableCellWithIdentifier("\(DetailTableViewCell.self)", forIndexPath: ip) as! DetailTableViewCell
            cell.descLabel.text = i.value.desc
            return cell
        }
        tvDataSource.titleForHeaderInSection = { $0.0.sectionAtIndex($0.1).model }
        
        viewModel = ContentViewModel(input: (day: day.asObservable(), d: 1))
        
        viewModel.elements.asObservable()
            .bindTo(tableView.rx_itemsWithDataSource(tvDataSource))
            .addDisposableTo(rx_disposeBag)
        
        viewModel.image.asDriver().drive(headImageView.rx_image)
            .addDisposableTo(rx_disposeBag)

        viewModel.imageLoading.asDriver().drive(imageActivityIndicatorView.rx_animating)
            .addDisposableTo(rx_disposeBag)
        
        viewModel.imageLoading.asDriver()
            .map { !$0 }
            .drive(navigationItem.rightBarButtonItem!.rx_enabled)
            .addDisposableTo(rx_disposeBag)
        
        tableView.rx_modelSelected(IdentifiableValue<GankModel>).subscribeNext { [unowned self] model in
            let sfController = SFSafariViewController(URL: NSURL(string: model.value.url)!, entersReaderIfAvailable: true)
            sfController.view.tintColor = Config.Color.blackColor
            self.presentViewController(sfController, animated: true, completion: nil)
            }
            .addDisposableTo(rx_disposeBag)

        navigationItem.rightBarButtonItem?.rx_tap
            .withLatestFrom(viewModel.image.asDriver())
            .filterNil()
            .subscribeNext { [unowned self] image in
                let shareURL = NSURL(string: "http://gank.io/\(self.day.value.toString(.Custom("yyyy/MM/dd"))!)")!
                let itemProvider = NSItemProvider()
                itemProvider.registerItemForTypeIdentifier(kUTTypeURL as String) {
                    completionHandler, expectedClass, options in
                    completionHandler(shareURL, nil)
                }
                itemProvider.previewImageHandler = { completionHandler, expectedClass, options in
                    completionHandler(image, nil)
                }
                // 个人认为这里的 activityItems 应该强制换成 NSItemProvider ，然后我们的 UIActivity 也可以进行统一的检测了~ 这里不统一会很麻烦 ==
                let vc = UIActivityViewController(activityItems: [self.headImageView.image!, shareURL],
                    applicationActivities: [GKSafariActivity()])
                self.presentViewController(vc, animated: true, completion: nil)
            }
            .addDisposableTo(rx_disposeBag)
        
    }

}