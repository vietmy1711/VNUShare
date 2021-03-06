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
    
    var user: User?
    
    let db = Firestore.firestore()
    
    private let imvTop: UIImageView = {
        let imv = UIImageView()
        imv.image = #imageLiteral(resourceName: "Traffic")
        imv.translatesAutoresizingMaskIntoConstraints = false
        imv.contentMode = .scaleAspectFill
        imv.layer.masksToBounds = true
        return imv
    }() 
    
    private let lblGreet: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont(name: "Helvetica-Bold", size: 30)
        lbl.textColor = .white
        return lbl
    }()
    
    private let lblPoints: UILabel = {
        let lbl = UILabel()
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
        checkIfUserLoggedIn()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .systemPink
        navigationController?.setNavigationBarHidden(true, animated: animated)
        tabBarController?.tabBar.isHidden = false
        getUser()
        checkTrip()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    func checkIfUserLoggedIn() {
        if Auth.auth().currentUser != nil {
            getUser()
        } else {
            let alert = UIAlertController(title: "Có lỗi đã xảy ra", message: "Vui lòng đăng nhập lại", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Đăng nhập", style: .default, handler: { (_) in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true)
        }
    }
    
    func setupUI() {
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        view.addSubview(imvTop)
        view.addSubview(lblGreet)
        view.addSubview(lblPoints)
        view.addSubview(lblMenu)
        view.addSubview(menuTableView)
        
        imvTop.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        imvTop.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        imvTop.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        imvTop.heightAnchor.constraint(equalToConstant: 220).isActive = true
        
        lblGreet.topAnchor.constraint(equalTo: view.topAnchor, constant: 150).isActive = true
        lblGreet.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        lblGreet.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        lblGreet.bottomAnchor.constraint(equalTo: lblPoints.topAnchor, constant: -10).isActive = true
        
        lblPoints.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        lblPoints.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        
        lblMenu.topAnchor.constraint(equalTo: imvTop.bottomAnchor, constant: 20).isActive = true
        lblMenu.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        lblMenu.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        
        menuTableView.separatorStyle = .none
        menuTableView.topAnchor.constraint(equalTo: lblMenu.bottomAnchor, constant: 0).isActive = true
        menuTableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        menuTableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        menuTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
    }
    
    func getUser() {
        db.collection("users").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
            if document!.exists {
                let uid = Auth.auth().currentUser!.uid
                let email: String = document!.get("email") as! String
                let fullname: String = document!.get("fullname") as! String
                let phonenumber: String = document!.get("phonenumber") as! String
                let role: String = document!.get("role") as! String
                let pointsNS: NSNumber = document!.get("points") as! NSNumber
                let points: Int = pointsNS.intValue
                let avatarData = document!.get("avatar")
                let avatar = UIImage(data: avatarData as! Data)
                self.user = User(uid: uid, email: email, fullname: fullname, phonenumber: phonenumber, role: role, points: points, avatar: avatar!)
                self.menuTableView.reloadData()
                self.lblGreet.text = "Xin chào, \(self.user!.fullname)"
                self.lblPoints.text = "Bạn đang có \(points) điểm thưởng"
            } else {
                print("not exist")
            }
        }
    }
    
    func checkTrip() {
        
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if user?.role == "Tài xế" {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
        if indexPath.row == 0 {
            cell.lblMenu.text = "Di chuyển"
        } else {
            cell.lblMenu.text = "Nhận cuốc"
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if let currentUser = user {
                let mapPickVC = MapPickViewController()
                mapPickVC.user = currentUser
                mapPickVC.modalPresentationStyle = .fullScreen
                navigationController?.pushViewController(mapPickVC, animated: true)
            }
        } else {
            let findTripVC = FindTripViewController()
            findTripVC.modalPresentationStyle = .fullScreen
            findTripVC.navigationItem.title = "Nhận cuốc"
            navigationController?.pushViewController(findTripVC, animated: true)
        }
    }
}
