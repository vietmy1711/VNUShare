//
//  TripUserViewController.swift
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

class TripUserViewController: UIViewController {
    
    var trip: Trip?
    
    let db = Firestore.firestore()
    
    var originMarker: GMSMarker?
    var destinationMarker: GMSMarker?
    var driverMarker: GMSMarker?
    
    var locationManager = CLLocationManager()
    
    var mapView: GMSMapView = {
        var mapView = GMSMapView()
        mapView.isMyLocationEnabled = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        getDriverPosition()
    }
    
    func checkLocation() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways  {
            self.locationManager.startUpdatingLocation()
        } else {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func getDriverPosition() {
        db.collection("users").document((trip?.driverId)!)
        .addSnapshotListener { documentSnapshot, error in
          guard let document = documentSnapshot else {
            print("Error fetching document: \(error!)")
            return
          }
            let latNS: NSNumber = document.get("lat") as! NSNumber
            let lonNS: NSNumber = document.get("lon") as! NSNumber
            let lat = latNS.floatValue
            let lon = lonNS.floatValue
            let position = CLLocationCoordinate2DMake(CLLocationDegrees(lat), CLLocationDegrees(lon))
            self.driverMarker?.map = nil
            self.driverMarker = GMSMarker(position: position)
            self.driverMarker?.icon = UIImage(named: "img_driver")
            self.driverMarker?.map = self.mapView
            self.setupMarker()
            self.drawRoute(self.driverMarker!.position, self.originMarker!.position)
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
        originMarker?.icon = GMSMarker.markerImage(with: .systemBlue)
        originMarker?.appearAnimation = .pop
        originMarker?.title = trip?.originName
        originMarker?.snippet = trip?.originAddress
        originMarker?.map = mapView
        destinationMarker = GMSMarker(position: destination)
        destinationMarker?.map = mapView
        destinationMarker?.icon = GMSMarker.markerImage(with: .systemPink)
        destinationMarker?.appearAnimation = .pop
        destinationMarker?.title = trip?.destinationName
        destinationMarker?.snippet = trip?.destinationAddress
    }
    
    func drawRoute(_ originCoordinate: CLLocationCoordinate2D, _ destinationCoordinate: CLLocationCoordinate2D) {
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
                let bounds: GMSCoordinateBounds = GMSCoordinateBounds(coordinate: originCoordinate, coordinate: destinationCoordinate)
                bounds.includingCoordinate(self.driverMarker!.position)
                self.mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 20.0))
            }
            catch {
                print(error)
            }
        }
    }
}

