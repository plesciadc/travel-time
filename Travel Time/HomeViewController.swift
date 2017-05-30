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

class HomeViewController: BaseViewController, CLLocationManagerDelegate, WCSessionDelegate, MKMapViewDelegate {
    
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation = CLLocation()
    var gotInitialLocation = false
    var deltaLat = Double()
    var deltaLong = Double()
    var centerLat = Double()
    var centerLong = Double()
    var endLocation = CLLocationCoordinate2D()
    
    var homeAddress = [""]
    var workAddress = [""]
    var customAddress = [""]
    var session: WCSession?
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
        homeView.isUserInteractionEnabled = false
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        startSession()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startSession() {
        if WCSession.isSupported() {
            
            session = WCSession.default()
            session?.delegate = self
            session?.activate()
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        currentLocation = locations[0]
        if gotInitialLocation == false {
        getTime()
        gotInitialLocation = true
        }
        mapView.setCenter(currentLocation.coordinate, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.directionsLabel.text = "Unable to Get Your Location.\nPlease Check Your Connection."
            self.spinner.stopAnimating()
            self.greyBG.isHidden = true
            self.homeView.isUserInteractionEnabled = true
        }
        print(error.localizedDescription)
    }
    
    func sendToWatch() {
            let applicationDict = ["homeAddress": homeAddress, "workAddress": workAddress, "customAddress": customAddress]
            session?.transferUserInfo(applicationDict)
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Is Inactive")
        isActive = false
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default().activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        isActive = true
    }
    
    func updateUI() {
        self.spinner.stopAnimating()
        self.greyBG.isHidden = true
        self.homeView.isUserInteractionEnabled = true
        self.mapView.showsUserLocation = true
        let mapSpan = MKCoordinateSpanMake((deltaLat + 0.005), (deltaLong + 0.005))
        let centerCoordinate = CLLocationCoordinate2DMake(centerLat, centerLong)
        let coordinateRegion = MKCoordinateRegionMake(centerCoordinate, mapSpan)
        let startingPoint = Pins(title: "Starting Location", coordinate: currentLocation.coordinate)
        let endingPoint = Pins(title: "Ending Location", coordinate: endLocation)
        self.mapView.addAnnotation(startingPoint)
        self.mapView.addAnnotation(endingPoint)
        self.mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    func getTime() {
        let addressArray = UserDefaults.standard.value(forKey: "homeAddress") as! Array<String>
        let rawAddress = addressArray[0]
        let formattedAddress = rawAddress.replacingOccurrences(of: " ", with: "+")
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=" + "\(currentLocation.coordinate.latitude)" + "," + "\(currentLocation.coordinate.longitude)" + "&destination=" + formattedAddress + "&key=AIzaSyCM1YKymuB5ePN5-uX0KOtPGgae5tYSW0w&alternatives=true&departure_time=now")
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
                self.updateUI()
                }
                return
            }
            guard let data = data else {
                print("Data is empty")
                DispatchQueue.main.async {
                self.directionsLabel.text = "No Routes Found.\nAddress Format Incorrect."
                self.updateUI()
                }
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            dict = json as! Dictionary
            newDict = dict["routes"] as! NSArray
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
            
            // Check for errors
            if newDict.count < 1 {
                DispatchQueue.main.async {
                    self.directionsLabel.text = "No Routes Found.\nAddress Format Incorrect."
                    self.updateUI()
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
                self.updateUI()
                }
            }
        }
        
        task.resume()
    }

}
