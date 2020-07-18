//
//  UserCell.swift
//  VNUShare
//
//  Created by nam on 6/22/20.
//  Copyright © 2020 MM. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    
    let vwContainer: UIView = {
        let vw = UIView()
        vw.backgroundColor = .white
        vw.translatesAutoresizingMaskIntoConstraints = false
        return vw
    }()
    
    let vwSeperator: UIView = {
        let vw = UIView()
        vw.backgroundColor = .systemGray6
        vw.translatesAutoresizingMaskIntoConstraints = false
        return vw
    }()
    
    let imvAvatar: UIImageView = {
        let imv = UIImageView()
        imv.layer.masksToBounds = true
        imv.contentMode = .scaleAspectFill
        imv.layer.cornerRadius = 25
        imv.backgroundColor = .systemGray6
        imv.isUserInteractionEnabled = true
        imv.translatesAutoresizingMaskIntoConstraints = false
        return imv
    }()
    
    let stackViewLabel: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let lblName: UILabel = {
        let lbl = UILabel()
        lbl.backgroundColor = .white
        lbl.textColor = .black
        lbl.font = UIFont(name: "Helvetica-Bold", size: 16)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    let lblLastMessage: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor(red: 75/255, green: 75/255, blue: 75/255, alpha: 1)
        lbl.font = UIFont(name: "Helvetica", size: 16)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupCell(){
        contentView.addSubview(vwContainer)
        contentView.addSubview(vwSeperator)
        
        vwContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2).isActive = true
        vwContainer.bottomAnchor.constraint(equalTo: vwSeperator.topAnchor, constant: 0).isActive = true
        vwContainer.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 2).isActive = true
        vwContainer.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -2).isActive = true
        
        vwSeperator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1).isActive = true
        vwSeperator.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        vwSeperator.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true
        
        vwSeperator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        contentView.addSubview(imvAvatar)
        
        imvAvatar.topAnchor.constraint(equalTo: vwContainer.topAnchor, constant: 10).isActive = true
        imvAvatar.leftAnchor.constraint(equalTo: vwContainer.leftAnchor, constant: 10).isActive = true
        imvAvatar.bottomAnchor.constraint(equalTo: vwContainer.bottomAnchor, constant: -10).isActive = true
        
        imvAvatar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        imvAvatar.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        contentView.addSubview(stackViewLabel)
        
        stackViewLabel.topAnchor.constraint(equalTo: vwContainer.topAnchor, constant: 12).isActive = true
        stackViewLabel.bottomAnchor.constraint(equalTo: vwContainer.bottomAnchor, constant: -12).isActive = true
        stackViewLabel.leftAnchor.constraint(equalTo: imvAvatar.rightAnchor, constant: 10).isActive = true
        stackViewLabel.rightAnchor.constraint(equalTo: vwContainer.rightAnchor, constant: -10).isActive = true
        
        stackViewLabel.addArrangedSubview(lblName)
        stackViewLabel.addArrangedSubview(lblLastMessage)
        
    }
    
    func configCell(avatar: UIImage, name: String, lastMessage: String?) {
        imvAvatar.image = avatar
        lblName.text = name
        if let lastMess = lastMessage {
            lblLastMessage.text = lastMess
        } else {
            lblLastMessage.text = "Gửi tin nhắn ngay"
        }
    }
}
