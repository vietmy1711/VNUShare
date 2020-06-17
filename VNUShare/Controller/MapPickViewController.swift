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
    var resultsViewController = GMSAutocompleteResultsViewController()
    
    var lat: Double = 0
    var lon: Double = 0
    
    var sourcePlace: Place?
    var destinationPlace: Place?
    
    let vwContainer: UIView = {
        let vw = UIView()
        vw.layer.cornerRadius = 10
        vw.layer.shadowColor = UIColor.black.cgColor
        vw.layer.shadowOpacity = 0.2
        vw.layer.shadowOffset = .zero
        vw.layer.shadowRadius = 0.8
        vw.backgroundColor = .white
        //vw.backgroundColor = UIColor(red: 246/255, green: 248/255, blue: 251/255, alpha: 1)
        vw.translatesAutoresizingMaskIntoConstraints = false
        return vw
    }()
    
    let stackViewBtn: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let vwCurrent: UIView = {
        let vw = UIView()
        vw.backgroundColor = .clear
        vw.translatesAutoresizingMaskIntoConstraints = false
        return vw
    }()
    
    let imvCurrent: UIImageView = {
        let imv = UIImageView()
        imv.image = UIImage(systemName: "location")
        imv.tintColor = .gray
        imv.translatesAutoresizingMaskIntoConstraints = false
        return imv
    }()
    
    let vwToGo: UIView = {
        let vw = UIView()
        vw.backgroundColor = .clear
        vw.translatesAutoresizingMaskIntoConstraints = false
        return vw
    }()
    
    let imvToGo: UIImageView = {
        let imv = UIImageView()
        imv.image = UIImage(systemName: "car")
        imv.tintColor = .gray
        imv.translatesAutoresizingMaskIntoConstraints = false
        return imv
    }()
    
    let btnConfirm: UIButton = {
           let btn = UIButton()
           btn.backgroundColor = .systemPink
           btn.layer.cornerRadius = 10
           btn.setTitle("Đặt", for: .normal)
           btn.setTitleColor(.white, for: .normal)
           btn.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 17)
           //btn.addTarget(self, action: #selector(), for: .touchUpInside)
           btn.translatesAutoresizingMaskIntoConstraints = false
           return btn
       }()
    
    let btnCancel: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 10
        btn.layer.borderWidth = 2
        btn.setTitle("Hủy", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 17)
        btn.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let txfCurrent: UITextField = {
        let txf = UITextField()
        txf.backgroundColor = .white//UIColor(red: 246/255, green: 248/255, blue: 251/255, alpha: 1)
        txf.font = UIFont(name: "Helvetica-Bold", size: 17)
        txf.placeholder = "Vị trí hiện tại"
        txf.clearButtonMode = .whileEditing
        txf.spellCheckingType = .no
        txf.addTarget(self, action: #selector(autocompleteClicked(_:)), for: .touchDown)
        txf.translatesAutoresizingMaskIntoConstraints = false
        return txf
    }()
    
    let txfToGo: UITextField = {
        let txf = UITextField()
        txf.backgroundColor = .white//UIColor(red: 246/255, green: 248/255, blue: 251/255, alpha: 1)
        txf.font = UIFont(name: "Helvetica-Bold", size: 17)
        txf.placeholder = "Nơi cần đến"
        txf.clearButtonMode = .whileEditing
        txf.spellCheckingType = .no
        txf.addTarget(self, action: #selector(autocompleteClicked(_:)), for: .touchDown)
        txf.translatesAutoresizingMaskIntoConstraints = false
        return txf
    }()
    
    let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
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
        getCurrentPlaceName()
        setupMap()
        locationManager.requestLocation()
    }
    
    func setupUI() {
        
        view.addSubview(vwContainer)
        
        vwContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -6).isActive = true
        vwContainer.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 6).isActive = true
        vwContainer.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -6).isActive = true
        vwContainer.addSubview(verticalStackView)
        
        verticalStackView.topAnchor.constraint(equalTo: vwContainer.topAnchor, constant: 10).isActive = true
        verticalStackView.bottomAnchor.constraint(equalTo: vwContainer.bottomAnchor, constant: -10).isActive = true
        verticalStackView.leftAnchor.constraint(equalTo: vwContainer.leftAnchor, constant: 10).isActive = true
        verticalStackView.rightAnchor.constraint(equalTo: vwContainer.rightAnchor, constant: -10).isActive = true
        
        verticalStackView.addArrangedSubview(vwCurrent)
        verticalStackView.addArrangedSubview(vwToGo)
        verticalStackView.addArrangedSubview(stackViewBtn)
        
        stackViewBtn.addArrangedSubview(btnCancel)
        stackViewBtn.addArrangedSubview(btnConfirm)
        
        vwCurrent.addSubview(imvCurrent)
        vwCurrent.addSubview(txfCurrent)
            
        vwCurrent.heightAnchor.constraint(equalToConstant: 40).isActive = true
        vwToGo.heightAnchor.constraint(equalToConstant: 40).isActive = true
        btnConfirm.heightAnchor.constraint(equalToConstant: 40).isActive = true
        btnCancel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        imvCurrent.topAnchor.constraint(equalTo: vwCurrent.topAnchor, constant: 10).isActive = true
        imvCurrent.bottomAnchor.constraint(equalTo: vwCurrent.bottomAnchor, constant: -10).isActive = true
        imvCurrent.leftAnchor.constraint(equalTo: vwCurrent.leftAnchor, constant: 10).isActive = true
        imvCurrent.rightAnchor.constraint(equalTo: txfCurrent.leftAnchor, constant: -16).isActive = true
        
        imvCurrent.widthAnchor.constraint(equalToConstant: 20).isActive = true
        imvCurrent.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        txfCurrent.topAnchor.constraint(equalTo: vwCurrent.topAnchor, constant: 0).isActive = true
        txfCurrent.bottomAnchor.constraint(equalTo: vwCurrent.bottomAnchor, constant: 0).isActive = true
        txfCurrent.rightAnchor.constraint(equalTo: vwCurrent.rightAnchor, constant: 0).isActive = true
        
        vwToGo.addSubview(imvToGo)
        vwToGo.addSubview(txfToGo)
        
        imvToGo.topAnchor.constraint(equalTo: vwToGo.topAnchor, constant: 10).isActive = true
        imvToGo.bottomAnchor.constraint(equalTo: vwToGo.bottomAnchor, constant: -10).isActive = true
        imvToGo.leftAnchor.constraint(equalTo: vwToGo.leftAnchor, constant: 10).isActive = true
        imvToGo.rightAnchor.constraint(equalTo: txfToGo.leftAnchor, constant: -16).isActive = true
        
        imvToGo.widthAnchor.constraint(equalToConstant: 20).isActive = true
        imvToGo.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        txfToGo.topAnchor.constraint(equalTo: vwToGo.topAnchor, constant: 0).isActive = true
        txfToGo.bottomAnchor.constraint(equalTo: vwToGo.bottomAnchor, constant: 0).isActive = true
        txfToGo.rightAnchor.constraint(equalTo: vwToGo.rightAnchor, constant: 0).isActive = true
        
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
            
            if let currentPlace = placeLikelihoodList?.last?.place {
                self.txfCurrent.text = currentPlace.name
                
                let name = currentPlace.name ?? "No name"
                let address = currentPlace.formattedAddress ?? "No address"
                let coordinate = currentPlace.coordinate

                self.sourcePlace = Place(name: name, address: address, coordinate: coordinate)
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
    
    
    // Present the Autocomplete view controller when the button is pressed.
    @objc func autocompleteClicked(_ sender: UITextField) {
        let autocompleteController = SearchMapViewController()
        if sender == txfToGo {
            autocompleteController.toGo = true
        }
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    
    @objc func cancelButtonClicked() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func checkLocation() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways  {
            self.locationManager.startUpdatingLocation()
        } else {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func setToGoWithPlace(place: Place) {
        txfToGo.text = place.name
        destinationPlace = place
    }
    
    func setCurrentWithPlace(place: Place) {
        txfCurrent.text = place.name
        sourcePlace = place
    }
    
}

//MARK: - CLLocationManagerDelegate

extension MapPickViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            lat = location.coordinate.latitude
            lon = location.coordinate.longitude
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

//MARK: - SearchMapViewControllerDelegate

extension MapPickViewController: SearchMapViewControllerDelegate {
    
    func didUpdateWithPlace(place: Place, toGo: Bool) {
        if toGo == true {
            setToGoWithPlace(place: place)
        } else {
            setCurrentWithPlace(place: place)
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}

extension MapPickViewController: GMSMapViewDelegate {
    
}
