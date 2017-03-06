//
//  DownloadButton.swift
//  ZDT-DownloadVideo
//
//  Created by Sztanyi Szabolcs on 11/04/15.
//  Copyright (c) 2015 Sztanyi Szabolcs. All rights reserved.
//

import UIKit

class DownloadButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.white.cgColor
        
        layer.cornerRadius = 8.0
        
        setTitleColor(UIColor.white, for: UIControlState())
        setTitleColor(UIColor.lightGray, for: .highlighted)
    }
    
}
