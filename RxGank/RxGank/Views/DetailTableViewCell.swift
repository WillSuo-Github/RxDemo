//
//  DetailTableViewCell.swift
//  RxGank
//
//  Created by 宋宋 on 16/2/28.
//  Copyright © 2016年 DianQK. All rights reserved.
//

import UIKit

class DetailTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var descLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        descLabel.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.size.width - 60
    }

}
