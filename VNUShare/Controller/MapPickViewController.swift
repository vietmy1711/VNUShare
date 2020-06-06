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
    
    let locationManager = CLLocationManager()
    
    let placesClient = GMSPlacesClient()
    
    var lat: Double = 0
    var lon: Double = 0
    
    let marker = GMSMarker()
    let marker1 = GMSMarker()
    
    let vwContainer: UIView = {
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
        btn.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 14)
        btn.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
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
        
        // Do any additional setup after loading the view.
        setupUI()
        
    }
    
    override func loadView() {
        
        super.loadView()
        mapView.delegate = self
        locationManager.delegate = self
        
        checkLocation()
        
        getUserLocation()
        setupMap()
        locationManager.requestLocation()
        
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
                                                  UInt(GMSPlaceField.placeID.rawValue))!
        placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: fields, callback: {
          (placeLikelihoodList: Array<GMSPlaceLikelihood>?, error: Error?) in
          if let error = error {
            print("An error occurred: \(error.localizedDescription)")
            return
          }

          if let placeLikelihoodList = placeLikelihoodList {
            for likelihood in placeLikelihoodList {
              let place = likelihood.place
              print("Current Place name \(String(describing: place.name)) at likelihood \(likelihood.likelihood)")
              print("Current PlaceID \(String(describing: place.placeID))")
            }
          }
        })

    }
    
    func setupUI() {
        //        view.addSubview(mapView)
        //
        //        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        //        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        //        mapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        //        mapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        //
        view.addSubview(vwContainer)
        
        vwContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -6).isActive = true
        vwContainer.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 6).isActive = true
        vwContainer.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -6).isActive = true
        
        vwContainer.addSubview(btnCancel)
        
        
        
        btnCancel.topAnchor.constraint(equalTo: vwContainer.topAnchor, constant: 10).isActive = true
        btnCancel.bottomAnchor.constraint(equalTo: vwContainer.bottomAnchor, constant: -10).isActive = true
        btnCancel.leftAnchor.constraint(equalTo: vwContainer.leftAnchor, constant: 10).isActive = true
        btnCancel.rightAnchor.constraint(equalTo: vwContainer.rightAnchor, constant: -10).isActive = true
        btnCancel.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func getUserLocation() {
        locationManager.desiredAccuracy = .greatestFiniteMagnitude
        locationManager.activityType = .automotiveNavigation
        locationManager.distanceFilter = 1
    }
    
    func setupMap() {
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 16)
        mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.map = mapView
        view = mapView
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension MapPickViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            lat = location.coordinate.latitude
            lon = location.coordinate.longitude
            print(lat, lon)
            //let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 16)
            //mapView = GMSMapView.map(withFrame: .zero, camera: camera)
            mapView.animate(toLocation: CLLocationCoordinate2D(latitude: lat, longitude: lon))
            marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            marker.title = "Vị trí hiện tại"
            marker.map = mapView
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
