//
//  HomeViewController.swift
//  Travel Time
//
//  Created by Daniel Plescia on 2/28/17.
//  Copyright © 2017 Daniel Plescia. All rights reserved.
//

import UIKit
import CoreLocation
import WatchConnectivity
import MapKit

var globalAddress = ""

class HomeViewController: BaseViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation = CLLocation()
    var gotInitialLocation = false
    var deltaLat = Double()
    var deltaLong = Double()
    var centerLat = Double()
    var centerLong = Double()
    var endLocation = CLLocationCoordinate2D()
    
    var timer = Timer()
    var timerRunning = false
    var regionSet = false
    var bound = MKMapRect()
    var polylineCount = 0
    
    var homeAddress = [""]
    var workAddress = [""]
    var customAddress = [""]
    var isActive = false
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var directionsLabel: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var greyBG: UIView!
    @IBOutlet var homeView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        self.mapView.showsUserLocation = false
        self.regionSet = false
        self.addSlideMenuButton()
        self.addMapsMenuButton()
        self.convertAddress()
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        mapView.isUserInteractionEnabled = false
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations[0].coordinate.latitude != currentLocation.coordinate.latitude {
            currentLocation = locations[0]
            getTime()
            if gotInitialLocation == false {
                mapView.setCenter(currentLocation.coordinate, animated: true)
                gotInitialLocation = true
            }
        } else {
            if timerRunning == false {
            runTimer()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.directionsLabel.text = "Unable to Get Your Location.\nPlease Check Your Connection."
            self.spinner.stopAnimating()
            self.greyBG.isHidden = true
            self.mapView.isUserInteractionEnabled = true
        }
        locationManager.requestLocation()
        print(error.localizedDescription)
    }
    
    func convertAddress() {
        let addressArray = UserDefaults.standard.value(forKey: "homeAddress") as! Array<String>
        let rawAddress = addressArray[0]
        let formattedAddress = rawAddress.replacingOccurrences(of: " ", with: "+")
        globalAddress = formattedAddress

        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(rawAddress) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let destinationPlacemark = placemarks.first?.location
                else {
                    // handle no location found
                    return
            }
            
            self.endLocation = destinationPlacemark.coordinate
            self.locationManager.requestLocation()
        }
    }
    
    func updateUI(success: Bool) {
        self.spinner.stopAnimating()
        self.greyBG.isHidden = true
        self.mapView.isUserInteractionEnabled = true
        self.mapView.showsUserLocation = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    // New method for refreshing location every X seconds
    func startRefresh() {
        timerRunning = false
        locationManager.requestLocation()
        
    }
    // Method to run timer. Time interval to be replaced with user choice for updating
    func runTimer() {
        timerRunning = true
        timer = Timer.scheduledTimer(timeInterval: 5, target: self,   selector: (#selector(self.startRefresh)), userInfo: nil, repeats: false)
    }
    
    
    func getTime() {
        var summaryText = ""
        var count = 0
        var distance = 0.0
        polylineCount = 0
        
        let units = getUnits()
        
        let sourceLocation = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: endLocation, addressDictionary: nil)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)

        let sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = "Starting Location"
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.title = "Ending Location"
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        if self.regionSet == false {
        self.mapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
        }

        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        directionRequest.requestsAlternateRoutes = true
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            self.mapView.removeOverlays(self.mapView.overlays)
            for route in response.routes {
                count += 1
                self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
                if self.getUnits() == "miles" {
                    distance = route.distance / 1609.34
                } else {
                    distance = route.distance / 1000
                }
                var routeTime = ""
                if route.expectedTravelTime >= 4800 {
                routeTime = self.stringFromTimeInterval(interval: route.expectedTravelTime)
                } else {
                    let expectedTime = NSInteger(route.expectedTravelTime / 60)
                    routeTime = "\(expectedTime) minutes"
                }
                if count < response.routes.count {
                    summaryText.append("\(routeTime) via \(route.name) (\(distance.truncate(places: 1)) \(units))\n")
                } else {
                    summaryText.append("\(routeTime) via \(route.name) (\(distance.truncate(places: 1)) \(units))")
                }
            }
            if self.regionSet == false {
            self.regionSet = true
            let rect = response.routes[0].polyline.boundingMapRect
            self.bound = self.mapView.mapRectThatFits(rect, edgePadding: UIEdgeInsetsMake(90, 35, 35, 50))
            self.mapView.setRegion(MKCoordinateRegionForMapRect(self.bound), animated: false)
            }
            self.directionsLabel.text = summaryText
            self.updateUI(success: true)
            if self.timerRunning == false {
            self.runTimer()
            }
        }
    }
    
    func getUnits() -> String {
        if UserDefaults.standard.string(forKey: "distanceUnits") == "imperial" {
            return "miles"
        } else {
            return "km"
        }
    }
    
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        
        let ti = NSInteger(interval)
        
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        
        return String(format: "%0.2d hours %0.2d minutes",hours,minutes)
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 3.0
        // Run through lines and change as they go
        if polylineCount == 0 {
            renderer.strokeColor = UIColor.blue
            polylineCount += 1
        } else if polylineCount == 1 {
            renderer.strokeColor = UIColor.green
            polylineCount += 1
        } else if polylineCount == 2 {
            renderer.strokeColor = UIColor.red
            polylineCount += 1
        } else {
            renderer.strokeColor = UIColor.black
        }
        
        return renderer
    }
}

extension Double
{
    func truncate(places : Int)-> Double
    {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
