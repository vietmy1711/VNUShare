//
//  TripOverViewViewController.swift
//  VNUShare
//
//  Created by MM on 6/22/20.
//  Copyright © 2020 MM. All rights reserved.
//

import UIKit
import GoogleMaps

protocol TripOverViewViewControllerDelegate {
    func didAcceptTrip(trip: Trip)
    func didNotAcceptTrip(trip: Trip)
}

class TripOverViewViewController: UIViewController {

    var trip: Trip?
    
    var originMarker: GMSMarker?
    var destinationMarker: GMSMarker?
    
    let mapView = GMSMapLayer()
    
    let vwBtnContainer: UIView = {
        let vw = UIView()
        vw.translatesAutoresizingMaskIntoConstraints = false
        return vw
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        setupUI()
        setupMarker()
    }
    
    func setupUI() {
        
    }
    
    func setupMarker() {
        
    }
    
}
