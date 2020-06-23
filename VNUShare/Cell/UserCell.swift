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
        vw.backgroundColor = .systemTeal
        vw.translatesAutoresizingMaskIntoConstraints = false
        return vw
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
        
        vwContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        vwContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        vwContainer.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        vwContainer.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true
        
        vwContainer.heightAnchor.constraint(equalToConstant: 100).isActive = true

    }
    func printSomething() {
        print("something")
    }
}
