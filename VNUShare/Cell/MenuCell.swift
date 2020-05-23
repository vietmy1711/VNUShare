//
//  MenuCell.swift
//  VNUShare
//
//  Created by MM on 5/22/20.
//  Copyright © 2020 MM. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {
    
    let vwView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .systemTeal
        vw.layer.masksToBounds = false
        vw.layer.cornerRadius = 20
        vw.layer.shadowColor = UIColor.black.cgColor
        vw.layer.shadowRadius = 1
        vw.layer.shadowOffset = .zero
        vw.layer.shadowOpacity = 0.2
        vw.translatesAutoresizingMaskIntoConstraints = false
        return vw
    }()
    
    let vwContainer: UIView = {
        let vw = UIView()
        vw.backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
        vw.layer.cornerRadius = 20
        vw.layer.masksToBounds = true
        vw.translatesAutoresizingMaskIntoConstraints = false
        return vw
    }()
    
    let imvMenu: UIImageView = {
        let imv = UIImageView()
        imv.contentMode = .scaleAspectFill
        imv.image = UIImage(named: "Bike")
        imv.translatesAutoresizingMaskIntoConstraints = false

        return imv
    }()
    
    let lblMenu: UILabel = {
        let lbl = UILabel()
        lbl.text = "Alo alo"
        lbl.textAlignment = .center
        lbl.font = UIFont(name: "Helvetica-Bold", size: 16)
        lbl.textColor = UIColor(red: 84/255, green: 84/255, blue: 84/255, alpha: 1)
        lbl.translatesAutoresizingMaskIntoConstraints = false

        return lbl
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupCell()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func setupCell() {
        contentView.addSubview(vwView)
        
        vwView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12).isActive = true
        vwView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12).isActive = true
        vwView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 24).isActive = true
        vwView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -24).isActive = true
        vwView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        vwView.addSubview(vwContainer)
        
        vwContainer.topAnchor.constraint(equalTo: vwView.topAnchor).isActive = true
        vwContainer.bottomAnchor.constraint(equalTo: vwView.bottomAnchor).isActive = true
        vwContainer.leftAnchor.constraint(equalTo: vwView.leftAnchor).isActive = true
        vwContainer.rightAnchor.constraint(equalTo: vwView.rightAnchor).isActive = true

        vwContainer.addSubview(imvMenu)
        vwContainer.addSubview(lblMenu)
        
        imvMenu.topAnchor.constraint(equalTo: vwContainer.topAnchor).isActive = true
        imvMenu.leftAnchor.constraint(equalTo: vwContainer.leftAnchor).isActive = true
        imvMenu.rightAnchor.constraint(equalTo: vwContainer.rightAnchor).isActive = true
        //imvMenu.heightAnchor.constraint(equalToConstant: 160).isActive = true

        lblMenu.topAnchor.constraint(equalTo: imvMenu.bottomAnchor, constant: 24).isActive = true
        lblMenu.bottomAnchor.constraint(equalTo: vwContainer.bottomAnchor, constant: -10).isActive = true
        lblMenu.leftAnchor.constraint(equalTo: vwContainer.leftAnchor).isActive = true
        lblMenu.rightAnchor.constraint(equalTo: vwContainer.rightAnchor).isActive = true
        
    }
    
}
