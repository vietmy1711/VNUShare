//
//  ReceiveChatCell.swift
//  VNUShare
//
//  Created by nam on 7/7/20.
//  Copyright © 2020 MM. All rights reserved.
//

import UIKit

class ReceiveChatCell: UITableViewCell {
    
    @IBOutlet weak var imvAvatar: UIImageView!
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imvAvatar.image = nil
        lblContent.text = nil
    }
    
    func setupUI(){
        imvAvatar.layer.cornerRadius = 16
        vwContainer.layer.cornerRadius = 8
        
    }
    
    func configWithContent(_ content: String,_ img: UIImage?) {
        lblContent.text = content
        imvAvatar.image = img
    }
}
