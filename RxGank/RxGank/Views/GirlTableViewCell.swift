//
//  GirlTableViewCell.swift
//  RxGank
//
//  Created by 宋宋 on 16/2/28.
//  Copyright © 2016年 DianQK. All rights reserved.
//

import UIKit

class GirlTableViewCell: UITableViewCell {

    @IBOutlet weak var contentImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentImageView.layer.masksToBounds = true
    }
    
}
