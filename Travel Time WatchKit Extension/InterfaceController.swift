//
//  InterfaceController.swift
//  Travel Time WatchKit Extension
//
//  Created by Daniel Plescia on 2/28/17.
//  Copyright © 2017 Daniel Plescia. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation
import WatchConnectivity

var homeAddress = [String]()

var workAddress = [String]()

var customAddress1 = [String]()

var customAddress2 = [String]()

var customAddress3 = [String]()


class InterfaceController: WKInterfaceController, CLLocationManagerDelegate, WCSessionDelegate {
    
    // Location manager variable
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation = CLLocation()
    var locationSet = false
    
    let travelData = GlobalTravelData.sharedGlobalTravel
    
    // WCSession variables
    var session: WCSession?
    var sessionActive = false
    var adressesSet = false
    
    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var customButton: WKInterfaceButton!
    @IBOutlet var workButton: WKInterfaceButton!
    @IBOutlet var homeButton: WKInterfaceButton!
    
    @IBAction func homeClicked() {
        pushController(withName: "HomeViewController", context: currentLocation)
    }
    @IBAction func workClicked() {
        pushController(withName: "WorkViewController", context: currentLocation)
    }
    @IBAction func customClicked() {
        pushController(withName: "CustomViewController", context: currentLocation)
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        startSession()
        titleLabel.setText("Getting Your Location")
        homeButton.setEnabled(false)
        workButton.setEnabled(false)
        customButton.setEnabled(false)
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestLocation()
        checkAddress()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        titleLabel.setText("Getting Your Location")
        homeButton.setEnabled(false)
        workButton.setEnabled(false)
        customButton.setEnabled(false)
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        currentLocation = locations[0]
        locationSet = true
        allowInteraction()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func allowInteraction() {
        if (locationSet == true) {
        homeButton.setEnabled(true)
        workButton.setEnabled(true)
        customButton.setEnabled(true)
        WKInterfaceDevice.current().play(.click)
        titleLabel.setText("Select a Destination:")
        }
    }
    
    func checkAddress() {
        if UserDefaults.standard.value(forKey: "homeAddress") == nil {
            UserDefaults.standard.setValue([""], forKey: "homeAddress")
        }
        if UserDefaults.standard.value(forKey: "workAddress") == nil {
            UserDefaults.standard.setValue([""], forKey: "workAddress")
        }
        if UserDefaults.standard.value(forKey: "customAddress1") == nil {
            UserDefaults.standard.setValue([""], forKey: "customAddress1")
        }
        if UserDefaults.standard.value(forKey: "customAddress2") == nil {
            UserDefaults.standard.setValue([""], forKey: "customAddress2")
        }
        if UserDefaults.standard.value(forKey: "customAddress3") == nil {
            UserDefaults.standard.setValue([""], forKey: "customAddress3")
        }
    }
    
    // Start WCSession functions
    func startSession() {
        
        if WCSession.isSupported() {
            
            session = WCSession.default()
            session?.delegate = self
            session?.activate()
            
        }
        
    }
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        sessionActive = true
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        DispatchQueue.main.async(execute: { () -> Void in
            
            if let retrievedArray1 = userInfo["homeAddress"] as? [String] {
                
                homeAddress = retrievedArray1
                UserDefaults.standard.setValue(homeAddress[0], forKey: "homeAddress")
                
            }
            
            if let retrievedArray2 = userInfo["workAddress"] as? [String] {
                
                workAddress = retrievedArray2
                UserDefaults.standard.setValue(workAddress[0], forKey: "workAddress")
                
            }
            
            if let retrievedArray3 = userInfo["customAddress1"] as? [String] {
                
                customAddress1 = retrievedArray3
                UserDefaults.standard.setValue(customAddress1[0], forKey: "customAddress1")
                
            }
            
            if let retrievedArray4 = userInfo["customAddress2"] as? [String] {
                
                customAddress2 = retrievedArray4
                UserDefaults.standard.setValue(customAddress2[0], forKey: "customAddress2")
                
            }
            
            if let retrievedArray5 = userInfo["customAddress3"] as? [String] {
                
                customAddress3 = retrievedArray5
                UserDefaults.standard.setValue(customAddress3[0], forKey: "customAddress3")
                
            }
            self.allowInteraction()
        })

    }
    
}

