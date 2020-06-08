//
//  MapPickViewController.swift
//  VNUShare
//
//  Created by MM on 5/25/20.
//  Copyright © 2020 MM. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces

class MapPickViewController: UIViewController {
    
    var locationManager = CLLocationManager()
    
    var placesClient = GMSPlacesClient()
    
    var lat: Double = 0
    var lon: Double = 0

    let vwBtnContainer: UIView = {
        let vw = UIView()
        vw.layer.cornerRadius = 10
        vw.layer.shadowColor = UIColor.black.cgColor
        vw.layer.shadowOpacity = 0.2
        vw.layer.shadowOffset = .zero
        vw.layer.shadowRadius = 0.8
        vw.backgroundColor = UIColor(red: 246/255, green: 248/255, blue: 251/255, alpha: 1)
        vw.translatesAutoresizingMaskIntoConstraints = false
        return vw
    }()

    let btnCancel: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 10
        btn.setTitle("Hủy", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 17)
        btn.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let txfCurrent: UITextField = {
        let txf = UITextField()
        txf.backgroundColor = UIColor(red: 246/255, green: 248/255, blue: 251/255, alpha: 1)
        txf.font = UIFont(name: "Helvetica-Bold", size: 17)
        txf.placeholder = "Vị trí hiện tại"
        txf.translatesAutoresizingMaskIntoConstraints = false
        return txf
    }()
    
    let txfToGo: UITextField = {
        let txf = UITextField()
        txf.backgroundColor = UIColor(red: 246/255, green: 248/255, blue: 251/255, alpha: 1)
        txf.font = UIFont(name: "Helvetica-Bold", size: 17)
        txf.placeholder = "Nơi cần đến"
        txf.translatesAutoresizingMaskIntoConstraints = false
        return txf
    }()
    
    let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    var mapView: GMSMapView = {
        var mapView = GMSMapView()
        mapView.isMyLocationEnabled = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        placesClient = GMSPlacesClient.shared()
        setupUI()
        
    }
    
    override func loadView() {
        
        super.loadView()
        mapView.delegate = self
        locationManager.delegate = self
        checkLocation()
        
        getUserLocation()
        //getCurrentPlaceName()
        setupMap()
        locationManager.requestLocation()
        
    }
    
    func setupUI() {

        view.addSubview(vwBtnContainer)
        
        vwBtnContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -6).isActive = true
        vwBtnContainer.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 6).isActive = true
        vwBtnContainer.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -6).isActive = true
        
        vwBtnContainer.addSubview(verticalStackView)
        
        verticalStackView.topAnchor.constraint(equalTo: vwBtnContainer.topAnchor, constant: 10).isActive = true
        verticalStackView.bottomAnchor.constraint(equalTo: vwBtnContainer.bottomAnchor, constant: -10).isActive = true
        verticalStackView.leftAnchor.constraint(equalTo: vwBtnContainer.leftAnchor, constant: 10).isActive = true
        verticalStackView.rightAnchor.constraint(equalTo: vwBtnContainer.rightAnchor, constant: -10).isActive = true

        verticalStackView.addArrangedSubview(txfCurrent)
        verticalStackView.addArrangedSubview(txfToGo)
        verticalStackView.addArrangedSubview(btnCancel)

        txfCurrent.heightAnchor.constraint(equalToConstant: 40).isActive = true
        txfToGo.heightAnchor.constraint(equalToConstant: 40).isActive = true
        btnCancel.heightAnchor.constraint(equalToConstant: 40).isActive = true

    }
    
    func getCurrentPlaceName() {
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
        UInt(GMSPlaceField.placeID.rawValue))!
        placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: fields, callback: {
          (placeLikelihoodList: Array<GMSPlaceLikelihood>?, error: Error?) in
          if let error = error {
            print("An error occurred: \(error.localizedDescription)")
            return
          }

            if let currentPlaceName = placeLikelihoodList?.last?.place.name {
                self.txfCurrent.text = currentPlaceName
            }
        })
    }
    
    func getUserLocation() {
        locationManager.desiredAccuracy = .greatestFiniteMagnitude
        locationManager.activityType = .automotiveNavigation
        locationManager.distanceFilter = 1
    }
    
    func setupMap() {
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 16)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        //        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        //        marker.title = "Sydney"
        //        marker.map = mapView
        self.view.addSubview(mapView)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 150, right: 0)
    }
    
    @objc func cancelButtonClicked() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func checkLocation() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways  {
            print("Start updating location")
            self.locationManager.startUpdatingLocation()
        } else {
            
            self.locationManager.requestWhenInUseAuthorization()
        }
    }

}

extension MapPickViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            lat = location.coordinate.latitude
            lon = location.coordinate.longitude
            print(lat, lon)
            mapView.animate(toLocation: CLLocationCoordinate2D(latitude: lat, longitude: lon))
            
        }
        else {
            print("No location")
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Did fail with error: \(error)")
    }
}

extension MapPickViewController: GMSMapViewDelegate {
    
}

