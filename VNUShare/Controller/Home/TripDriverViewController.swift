//
//  TripDriverViewController.swift
//  VNUShare
//
//  Created by MM on 6/22/20.
//  Copyright © 2020 MM. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON
import Firebase

class TripDriverViewController: UIViewController {
    
    var trip: Trip?
    
    let db = Firestore.firestore()
    
    var originMarker: GMSMarker?
    var destinationMarker: GMSMarker?
    
    var locationManager = CLLocationManager()
    
    var currentLocation: CLLocationCoordinate2D?
    
    var firstTime = true
    var state = "accepted"
    
    var mapView: GMSMapView = {
        var mapView = GMSMapView()
        mapView.isMyLocationEnabled = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func loadView() {
        super.loadView()
        checkLocation()
        setupMap()
        setupMarker()
    }
    
    func checkLocation() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways  {
            self.locationManager.startUpdatingLocation()
        } else {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func setupMap() {
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 16)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        self.view.addSubview(mapView)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
    }
    
    func setupMarker() {
        let origin = CLLocationCoordinate2DMake(CLLocationDegrees(trip!.originLatitude), CLLocationDegrees(trip!.originLongitude))
        let destination = CLLocationCoordinate2DMake(CLLocationDegrees(trip!.destinationLatitude), CLLocationDegrees(trip!.destinationLongitude))
        originMarker = GMSMarker(position: origin)
        originMarker?.map = mapView
        destinationMarker = GMSMarker(position: destination)
        destinationMarker?.map = mapView
    }
    
    func drawRoute(_ originCoordinate: CLLocationCoordinate2D, _ destinationCoordinate: CLLocationCoordinate2D) {
        mapView.clear()
        setupMarker()
        let origin = "\(originCoordinate.latitude),\(originCoordinate.longitude)"
        let destination = "\(destinationCoordinate.latitude),\(destinationCoordinate.longitude)"
        let apiKey = API().APIKey
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(apiKey)"
        
        AF.request(url).responseJSON { response in
            do {
                let json = try JSON(data: response.data!)
                let routes = json["routes"].arrayValue
                for route in routes
                {
                    let routeOverviewPolyline = route["overview_polyline"].dictionary
                    let points = routeOverviewPolyline?["points"]?.stringValue
                    let path = GMSPath.init(fromEncodedPath: points!)
                    let polyline = GMSPolyline(path: path)
                    polyline.strokeColor = .systemGreen
                    polyline.strokeWidth = 10.0
                    polyline.map = self.mapView
                }
                if self.firstTime == true {
                let bounds: GMSCoordinateBounds = GMSCoordinateBounds(coordinate: originCoordinate, coordinate: destinationCoordinate)
                self.mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 20.0))
                    self.firstTime = false
                }
            }
            catch {
                print(error)
            }
        }
    }
    
    func setState() {
        switch self.state {
        case "accepted":
            let origin = CLLocationCoordinate2DMake(CLLocationDegrees(trip!.originLatitude), CLLocationDegrees(trip!.originLongitude))
            drawRoute(currentLocation!, origin)
        case "finished":
            mapView.clear()
        default:
            let destination = CLLocationCoordinate2DMake(CLLocationDegrees(trip!.destinationLatitude), CLLocationDegrees(trip!.destinationLongitude))
            drawRoute(currentLocation!, destination)
        }
    }
}

//MARK: - CLLocationManagerDelegate

extension TripDriverViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            currentLocation = CLLocationCoordinate2DMake(lat, lon)
            mapView.animate(toLocation: CLLocationCoordinate2D(latitude: lat, longitude: lon))
            if let locationFromMap = mapView.myLocation {
                db.collection("users").document(Auth.auth().currentUser!.uid).updateData(
                    [
                        "lat": locationFromMap.coordinate.latitude,
                        "lon": locationFromMap.coordinate.longitude,
                        "course": locationFromMap.course

                ]) { err in
                    if let err = err {
                        print(err)
                    } else {
                        self.setState()
                    }
                }
            }
        }
        else {
            print("No location")
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Did fail with error: \(error)")
    }
}
