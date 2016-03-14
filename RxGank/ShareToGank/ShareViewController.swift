//
//  ShareViewController.swift
//  ShareToGank
//
//  Created by 宋宋 on 16/3/13.
//  Copyright © 2016年 DianQK. All rights reserved.
//

import UIKit
import Social
import Alamofire
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {
    
    lazy var optionItem:SLComposeSheetConfigurationItem = { [unowned self] in
        let sl = SLComposeSheetConfigurationItem()
        sl.title = "选项"
        sl.value = "\(self.optionData.id), \(self.optionData.type)"
        if self.optionData.debug {
            sl.value.appendContentsOf(", Debug")
        }
        sl.tapHandler = {
            let option = UIStoryboard(name: "MainInterface", bundle: nil).instantiateViewControllerWithIdentifier("OptionViewController") as! OptionViewController
            option.delegate = self
            option.optionData = self.optionData
            self.pushConfigurationViewController(option)
        }
        return sl
    }()
    
    lazy var optionData: OptionData = {
        return OptionData(id: "DianQK", type: .iOS, debug: true)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        let viewController = navigationController!.viewControllers.first!
        let navigationItem = viewController.navigationItem
        navigationItem.leftBarButtonItem?.title = "取消"
        navigationItem.rightBarButtonItem?.title = "分享"
        
        charactersRemaining = 10 // 更新需要重新设置 ==
        
    }

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return contentText.characters.count >= 5
    }

    override func didSelectPost() {

        guard let inputItem = extensionContext?.inputItems.first as? NSExtensionItem else { return }
        inputItem.attachments?.forEach { // 如果用 Rx
            guard let provider = $0 as? NSItemProvider else { return }
            guard let dataType = provider.registeredTypeIdentifiers.first as? String else { return }
            if dataType == kUTTypeURL as String {
                provider.loadItemForTypeIdentifier(dataType, options: nil) { [unowned self] (secureCoding, error) -> Void in
                    let url: NSURL = secureCoding as! NSURL
                    let parameters = [
                        "url": url, "desc": self.contentText,
                        "who": self.optionData.id,
                        "type": self.optionData.type.rawValue,
                        "debug": self.optionData.debug.description
                    ]
                    Alamofire.request(.POST, "https://gank.io/api/add2gank", parameters: parameters)
                        .responseJSON{ response -> Void in
                        print(response)
                    }
                }
            }
        }

        self.extensionContext!.completeRequestReturningItems([], completionHandler: nil)
        
    }
    
    override func loadPreviewView() -> UIView! {
        return UIView()
    }

    override func configurationItems() -> [AnyObject]! {

        return [optionItem]
    }

}

extension ShareViewController: OptionSelectionViewControllerDelegate {
    
    func optionSelection(selected: OptionData) { // 如果用 Rx ==
        optionData = selected
        optionItem.value = "\(selected.id), \(selected.type)"
        if selected.debug {
            optionItem.value.appendContentsOf(", Debug")
        }
        
    }
}
