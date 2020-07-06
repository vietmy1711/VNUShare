//
//  AccountViewController.swift
//  VNUShare
//
//  Created by MM on 4/23/20.
//  Copyright © 2020 MM. All rights reserved.
//

import UIKit
import Firebase

class AccountViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    var user: User?
    
    var imagePicker = UIImagePickerController()
    
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
    
    let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let btnStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let vwSeperator: UIView = {
        let vw = UIView()
        vw.backgroundColor = .systemGray6
        vw.translatesAutoresizingMaskIntoConstraints = false
        return vw
    }()
    
    let lblName: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = UIFont(name: "Helvetica-Bold", size: 17)
        lbl.textAlignment = .left
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    let lblPhonenumber: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor(red: 75/255, green: 75/255, blue: 75/255, alpha: 1)
        lbl.font = UIFont(name: "Helvetica", size: 16)
        lbl.textAlignment = .left
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    let btnHistory: UIButton = {
        let btn = UIButton()
        btn.setTitle("Lịch sử chuyến đi", for: .normal)
        btn.setTitleColor(UIColor(red: 75/255, green: 75/255, blue: 75/255, alpha: 1), for: .normal)
        btn.setTitleColor(UIColor(red: 75/255, green: 75/255, blue: 75/255, alpha: 0.5), for: .highlighted)
        btn.titleLabel!.font = UIFont(name: "Helvetica", size: 17)
        btn.backgroundColor = .clear
        btn.addTarget(self, action: #selector(btnHistoryPressed), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let btnSignOut: UIButton = {
        let btn = UIButton()
        btn.setTitle("Đăng xuất", for: .normal)
        btn.setTitleColor(.systemPink, for: .normal)
        btn.addTarget(self, action: #selector(btnSignOutPressed), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUser()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.navigationBar.tintColor = .systemPink
        tabBarController?.tabBar.isHidden = false
    }
    func setupUI() {
        view.addSubview(imvAvatar)
        
        imvAvatar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24).isActive = true
        imvAvatar.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 24).isActive = true
        imvAvatar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        imvAvatar.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(imvOnClicked))
        imvAvatar.addGestureRecognizer(tap)
        
        view.addSubview(verticalStackView)
        
        verticalStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        verticalStackView.leftAnchor.constraint(equalTo: imvAvatar.rightAnchor, constant: 24).isActive = true
        verticalStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -24).isActive = true
        
        verticalStackView.addArrangedSubview(lblName)
        verticalStackView.addArrangedSubview(lblPhonenumber)
        
        view.addSubview(vwSeperator)
        vwSeperator.topAnchor.constraint(equalTo: verticalStackView.bottomAnchor, constant: 20).isActive = true
        vwSeperator.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        vwSeperator.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
        vwSeperator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        view.addSubview(btnStackView)
        
        btnStackView.topAnchor.constraint(equalTo: vwSeperator.bottomAnchor, constant: 30).isActive = true
        btnStackView.leftAnchor.constraint(equalTo: vwSeperator.leftAnchor, constant: 10).isActive = true
        btnStackView.rightAnchor.constraint(equalTo: vwSeperator.rightAnchor, constant: -10).isActive = true
        
        btnStackView.addArrangedSubview(btnHistory)
        
        view.addSubview(btnSignOut)
        btnSignOut.topAnchor.constraint(equalTo: btnStackView.bottomAnchor, constant: 30).isActive = true
        btnSignOut.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
    }
    
    func getUser() {
        db.collection("users").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
            if let error = error {
                print(error)
            } else {
                if let document = document {
                    let avatarData = document.get("avatar")
                    self.imvAvatar.image = UIImage(data: avatarData as! Data)
                    
                    let uid = document.documentID
                    let email = document.get("email") as! String
                    let phonenumber = document.get("phonenumber") as! String
                    let fullname = document.get("fullname") as! String
                    let role = document.get("role") as! String
                    let pointsNS: NSNumber = document.get("points") as! NSNumber
                    let points: Int = pointsNS.intValue
                    self.user = User(uid: uid, email: email, fullname: fullname, phonenumber: phonenumber, role: role, points: points)
                    self.lblName.text = self.user!.fullname
                    self.lblPhonenumber.text = self.user!.phonenumber
                }
            }
        }
    }
    
    @objc func imvOnClicked() {
        let actionSheet = UIAlertController(title: "Đổi ảnh người dùng", message: "Vui lòng chọn phương thức đổi ảnh", preferredStyle: .actionSheet)
        let photoAction = UIAlertAction(title: "Truy cập ảnh", style: .default) { (_) in
            self.chooseFromPhoto()
        }
        let cameraAction = UIAlertAction(title: "Dùng camera", style: .default) { (_) in
            self.takePhoto()
        }
        let cancelAction = UIAlertAction(title: "Trở về", style: .cancel) { (_) in
        }
        actionSheet.addAction(photoAction)
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func chooseFromPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func takePhoto() {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    @objc func btnHistoryPressed() {
        let historyVC = HistoryViewController()
        historyVC.user = user
        historyVC.navigationItem.title = "Lịch sử"
        navigationController?.pushViewController(historyVC, animated: true)
    }
    
    @objc func btnSignOutPressed() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        self.dismiss(animated: true, completion: nil)
    }
}

extension AccountViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var chosenImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imvAvatar.image = chosenImage
        chosenImage = chosenImage.resizeImage(targetSize: CGSize(width: 500, height: 500))
        let imageData = chosenImage.pngData()
        db.collection("users").document(Auth.auth().currentUser!.uid).updateData(["avatar": imageData!]) { (error) in
            if let error = error {
                print(error)
            }
        }
        self.dismiss(animated: true)
    }
}

extension UIImage {
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
