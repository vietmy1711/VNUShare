//
//  SecondViewController.swift
//  VNUShare
//
//  Created by MM on 4/10/20.
//  Copyright © 2020 MM. All rights reserved.
//

import UIKit



class MessageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet var tableView: UITableView!
    

    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.searchController = searchController
        setupUI()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    }
    func search() {
        tableView.reloadData()
    }
    func setupUI() {
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell")
        tableView.register(UINib(nibName: "SecondCell", bundle: nil), forCellReuseIdentifier: "SecondCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //imageClicked(row: indexPath.row)
        //        let sendingRow = Int(indexPath.row)
        //        currentRow = sendingRow
        //        if delegate == nil {
        //            print("delegate MessageViewController = nil")
        //        }
        //        else {
        //            delegate?.position(sentRow: sendingRow)
        //        }
        //        print("\(indexPath.row)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        if textSearch.isEmpty {
        //            return array()
        //        }
        //        return arraySearch().count
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       let userCell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
       //        if textSearch.isEmpty {
       //            object = array[indexPath.row]
       //        }
       //        else {
       //            object = arraySearch[indexPath.row]
       //        }
       //userCell.receivedRow = indexPath.row
       //userCell.delegate = self
       //userCell.vieContainer.backgroundColor = .red
        return userCell
    }
    
}



