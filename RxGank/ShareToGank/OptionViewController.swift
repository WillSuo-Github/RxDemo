//
//  OptionViewController.swift
//  RxGank
//
//  Created by 宋宋 on 16/3/14.
//  Copyright © 2016年 DianQK. All rights reserved.
//

import UIKit



enum GankType: String {
    case Android = "Android"
    case iOS = "iOS"
    case 休息视频 = "休息视频"
    case 福利 = "福利"
    case 拓展资源 = "拓展资源"
    case 前端 = "前端"
    case 瞎推荐 = "瞎推荐"
    case App = "App"
}

extension GankType {
    func convertInt() -> Int {
        switch self {
        case .iOS: return 0
        case .Android: return 1
        case .瞎推荐: return 2
        case .App: return 3
        default : return 0
        }
    }
    
    static func convertGankType(raw: Int) -> GankType {
        switch raw {
        case 0: return .iOS
        case 1: return .Android
        case 2: return .瞎推荐
        case 3: return .App
        default : return .iOS
        }
    }
}

protocol OptionSelectionViewControllerDelegate: class {
    func optionSelection(selected: OptionData)
}

typealias OptionData = (id: String, type: GankType, debug: Bool)

class OptionViewController: UITableViewController {
    
    @IBOutlet weak var userIdTextField: UITextField!
    
    @IBOutlet weak var gankTypeControl: UISegmentedControl!
    
    @IBOutlet weak var debugSwitch: UISwitch!
    
    var optionData: OptionData!
    
    weak var delegate: OptionSelectionViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userIdTextField.text = optionData.id
        debugSwitch.on = optionData.debug
        gankTypeControl.selectedSegmentIndex = optionData.type.convertInt()
        userIdTextField.addTarget(self, action: "updateUserId:", forControlEvents: .EditingChanged)
    }

    func updateUserId(sender: UITextField) {
        optionData.id = sender.text ?? ""
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        optionData.debug = debugSwitch.on
        optionData.type = GankType.convertGankType(gankTypeControl.selectedSegmentIndex)
        delegate?.optionSelection(optionData)
    }
}
