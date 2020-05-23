//
//  FirstViewController.swift
//  VNUShare
//
//  Created by MM on 4/10/20.
//  Copyright © 2020 MM. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    
    var coupon: Int = 0
    let greetingString: String = {
        guard let user = Auth.auth().currentUser else {
            return "No user logged in"
        }
        return "Hello \(String(describing: user.displayName!))"
    }()
    
    private let imvTop: UIImageView = {
        let imv = UIImageView()
        imv.image = #imageLiteral(resourceName: "Traffic")
        imv.translatesAutoresizingMaskIntoConstraints = false
        imv.contentMode = .scaleAspectFill
        return imv
    }()
    
    private let lblGreet: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont(name: "Helvetica-Bold", size: 30)
        lbl.textColor = .white
        return lbl
    }()
    
    private let lblCoupon: UILabel = {
        let lbl = UILabel()
        lbl.text = "Bạn có 0 coupon sẵn sàng sử dụng."
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont(name: "Helvetica-Bold", size: 16)
        lbl.textColor = .white
        return lbl
    }()
    
    private let lblMenu: UILabel = {
        let lbl = UILabel()
        lbl.text = "Bạn cần gì?"
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont(name: "Helvetica-Bold", size: 30)
        lbl.textColor = .black
        return lbl
    }()

    
    private let menuTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UINib(nibName: "MenuCell", bundle: nil), forCellReuseIdentifier: "MenuCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuTableView.delegate = self
        menuTableView.dataSource = self
        setupUI()
    }
    
    func setupUI() {
        view.addSubview(imvTop)
        view.addSubview(lblGreet)
        view.addSubview(lblCoupon)
        view.addSubview(lblMenu)
        view.addSubview(menuTableView)
        
        imvTop.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        imvTop.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        imvTop.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        imvTop.heightAnchor.constraint(equalToConstant: 240).isActive = true
        
        lblGreet.text = greetingString
        
        lblGreet.topAnchor.constraint(equalTo: view.topAnchor, constant: 180).isActive = true
        lblGreet.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        lblGreet.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        lblGreet.bottomAnchor.constraint(equalTo: lblCoupon.topAnchor, constant: -10).isActive = true
        
        lblCoupon.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        lblCoupon.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        
        lblMenu.topAnchor.constraint(equalTo: imvTop.bottomAnchor, constant: 40).isActive = true
        lblMenu.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        lblMenu.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        
        menuTableView.separatorStyle = .none
        menuTableView.topAnchor.constraint(equalTo: lblMenu.bottomAnchor, constant: 10).isActive = true
        menuTableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        menuTableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        menuTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
    }
    
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
        if indexPath.row == 0 {
            cell.lblMenu.text = "Di chuyển"
        } else {
            cell.lblMenu.text = "Ăn uống"
        }
        return cell
    }
}
