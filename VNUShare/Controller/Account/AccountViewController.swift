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
    
    var imagePicker = UIImagePickerController()
    
    let imvAvatar: UIImageView = {
        let imv = UIImageView()
        imv.layer.masksToBounds = true
        imv.contentMode = .scaleAspectFill
        imv.layer.cornerRadius = 80
        imv.backgroundColor = .gray
        imv.isUserInteractionEnabled = true
        imv.translatesAutoresizingMaskIntoConstraints = false
        return imv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getAvatar()
    }
    
    func setupUI() {
        view.addSubview(imvAvatar)
        
        imvAvatar.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        imvAvatar.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        imvAvatar.heightAnchor.constraint(equalToConstant: 160).isActive = true
        imvAvatar.widthAnchor.constraint(equalToConstant: 160).isActive = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(imvOnClicked))
        imvAvatar.addGestureRecognizer(tap)
    }
    
    func getAvatar() {
        db.collection("users").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
            if let error = error {
                print(error)
            } else {
                if let document = document {
                    let avatarData = document.get("avatar")
                    self.imvAvatar.image = UIImage(data: avatarData as! Data)
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
