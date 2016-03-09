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

//typealias TableSectionModel = AnimatableSectionModel<String, GankModel>

class ContentViewController: UITableViewController {
    
    @IBOutlet weak var headImageView: UIImageView!
    
    var model: DayModel?
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = nil
        tableView.delegate = nil
        tableView.sectionFooterHeight = 0
        
    }

}