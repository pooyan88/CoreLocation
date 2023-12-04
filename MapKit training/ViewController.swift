//
//  ViewController.swift
//  MapKit training
//
//  Created by Pooyan J on 9/13/1402 AP.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    @IBAction func locationButton(_ sender: Any) {
        guard let location = locationManager.location else { return }
        print(location.coordinate)
    }
    
    var locationManager: CLLocationManager = {
        var manager = CLLocationManager()
        manager.distanceFilter = 10
        manager.desiredAccuracy = kCLLocationAccuracyBest
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupLocationManager()
        locationImageView.layer.position.y -= locationImageView.bounds.height / 2
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}

//MARK: - Actions
extension ViewController {
    
    func render(_ location: CLLocation) {
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: CLLocationDistance(exactly: 1000)!, longitudinalMeters: CLLocationDistance(exactly: 1000)!)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        mapView.addAnnotation(pin)
    }
    
    func getAddress(coordinate: CLLocationCoordinate2D) {
        let address = CLGeocoder.init()
        address.reverseGeocodeLocation(CLLocation.init(latitude: coordinate.latitude, longitude: coordinate.longitude)) { (places, error) in
            if error == nil{
                if let place = places {
                    print(place)
                }
            }
        }
    }
    
    func convertLatLongToAddress(latitude: Double ,longitude: Double) {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            if let locationName = placeMark.location {
                print("LOCATION NAME =>", locationName)
            }
            if let street = placeMark.thoroughfare {
                print("STREET =>", street)
            }
            if let city = placeMark.locality {
                print("CITY =>", city)
            }
            if let state = placeMark.administrativeArea {
                print("STATE =>", state)
            }
            if let zipCode = placeMark.postalCode {
                print("ZIP CODE", zipCode)
            }
            if let country = placeMark.country {
                print("COUNTRY", country)
            }
        })
    }
    
    func getAddress() {
        let center = mapView.centerCoordinate
        convertLatLongToAddress(latitude: center.latitude, longitude: center.longitude)
    }
}

//MARK: - Delegate
extension ViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            manager.stopUpdatingLocation()
            render(location)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        getAddress()
    }
}

