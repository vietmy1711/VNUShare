//
//  SendChatCell.swift
//  VNUShare
//
//  Created by nam on 7/7/20.
//  Copyright © 2020 MM. All rights reserved.
//

import UIKit

class SendChatCell: UITableViewCell {

    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var lblContent: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupUI(){
        vwContainer.layer.cornerRadius = 8
        lblContent.layer.cornerRadius = 16
    }
    
    func configWithContent(_ content: String) {
        lblContent.text = content
    }
}
