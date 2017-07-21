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
    
    var homeAddress = [""]
    var workAddress = [""]
    var customAddress = [""]
    var isActive = false
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var directionsLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var greyBG: UIView!
    @IBOutlet var homeView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        self.mapView.showsUserLocation = false
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
            testGetTime()
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
        print(error.localizedDescription)
    }
    
    func convertAddress() {
        let addressArray = UserDefaults.standard.value(forKey: "homeAddress") as! Array<String>
        let rawAddress = addressArray[0]
        globalAddress = rawAddress

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
    
    
    func testGetTime() {
        let sourceLocation = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: endLocation, addressDictionary: nil)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)

        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.title = "Ending Location"
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        self.mapView.showAnnotations([destinationAnnotation], animated: true )

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
            for route in response.routes {
            self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
            var summaryText = ""
            let routeTime = route.expectedTravelTime / 60
            summaryText.append(routeTime + " minutes via " + route.name + " (" + route.distance + ")")
            }
            
            let rect = response.routes[0].polyline.boundingMapRect
            let bound = self.mapView.mapRectThatFits(rect, edgePadding: UIEdgeInsetsMake(90, 35, 35, 50))
            self.mapView.setRegion(MKCoordinateRegionForMapRect(bound), animated: false)
            self.updateUI(success: true)
            if self.timerRunning == false {
            self.runTimer()
            }
        }
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 3.0
        
        return renderer
    }
    
    
    func getTime() {
        let addressArray = UserDefaults.standard.value(forKey: "homeAddress") as! Array<String>
        var distanceUnits = ""
        if UserDefaults.standard.string(forKey: "distanceUnits") != nil {
        distanceUnits = UserDefaults.standard.string(forKey: "distanceUnits")!
        }
        else {
            distanceUnits = "imperial"
        }
        let rawAddress = addressArray[0]
        let formattedAddress = rawAddress.replacingOccurrences(of: " ", with: "+")
        globalAddress = formattedAddress
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=" + "\(currentLocation.coordinate.latitude)" + "," + "\(currentLocation.coordinate.longitude)" + "&destination=" + formattedAddress + "&key=AIzaSyCM1YKymuB5ePN5-uX0KOtPGgae5tYSW0w&alternatives=true&departure_time=now&units=" + distanceUnits)
        var dict = Dictionary<String, Any>()
        var newDict = NSArray()
        var finalArray = NSDictionary()
        var legs = NSArray()
        var legs2 = NSDictionary()
        var duration = NSDictionary()
        var distanceDict = NSDictionary()
        var distance = ""
        var time = ""
        var roads = ""
        var summaries:Array<String> = []
        var roadsList:Array<String> = []
        var summaryText = ""
        
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard error == nil else {
                print(error)
                DispatchQueue.main.async {
                self.directionsLabel.text = "No Routes Found.\nPlease Check Your Connection."
                self.updateUI(success: false)
                }
                return
            }
            guard let data = data else {
                print("Data is empty")
                DispatchQueue.main.async {
                self.directionsLabel.text = "No Routes Found.\nAddress Format Incorrect."
                self.updateUI(success: false)
                }
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            dict = json as! Dictionary
            newDict = dict["routes"] as! NSArray
            
            if newDict.count > 0 {
            // Set bounds
            let boundsDict = newDict[0] as! NSDictionary
            let bounds = boundsDict["bounds"] as! NSDictionary
            let northeast = bounds["northeast"] as! NSDictionary
            let southwest = bounds["southwest"] as! NSDictionary
            let boundsNorthLat = northeast["lat"] as! Double
            let boundsNorthLong = northeast["lng"] as! Double
            let boundsSouthLat = southwest["lat"] as! Double
            let boundsSouthLong = southwest["lng"] as! Double
            self.deltaLat = abs(boundsNorthLat - boundsSouthLat)
            self.deltaLong = abs(boundsNorthLong - boundsSouthLong)
            self.centerLat = (boundsNorthLat + boundsSouthLat)/2
            self.centerLong = (boundsNorthLong + boundsSouthLong)/2
            // Set Ending Point
            let legsArray = boundsDict["legs"] as! NSArray
            let finalLegs = legsArray[0] as! NSDictionary
            let endingDest = finalLegs["end_location"] as! NSDictionary
            let endingLat = endingDest["lat"] as! Double
            let endingLong = endingDest["lng"] as! Double
            self.endLocation = CLLocationCoordinate2DMake(endingLat, endingLong)
            }
            
            // Check for errors
            if newDict.count < 1 {
                DispatchQueue.main.async {
                    self.directionsLabel.text = "No Routes Found.\nAddress Format Incorrect."
                    self.updateUI(success: false)
                }
            }
            else {
                
                for i in 0...newDict.count - 1
                {
                    finalArray = newDict[i] as! NSDictionary
                    legs = finalArray["legs"] as! NSArray
                    legs2 = legs[0] as! NSDictionary
                    duration = legs2["duration_in_traffic"] as! NSDictionary
                    distanceDict = legs2["distance"] as! NSDictionary
                    distance = distanceDict["text"] as! String
                    time = duration["text"] as! String
                    roads = finalArray["summary"] as! String
                    summaries.append(time + " via " + roads + " (" + distance + ")")
                    if !(roadsList.contains(roads)) {
                        roadsList.append(roads)
                        if (i > 0) {
                            summaryText.append("\n" + summaries[i])
                        }else {
                            summaryText.append(summaries[i])
                        }
                    }
                }
                DispatchQueue.main.async {
                self.directionsLabel.text = summaryText
                self.updateUI(success: true)
                self.runTimer()
                }
            }
        }
        
        task.resume()
    }

}
