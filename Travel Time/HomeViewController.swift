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

class HomeViewController: BaseViewController, CLLocationManagerDelegate, WCSessionDelegate {
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    var homeAddress = [""]
    var workAddress = [""]
    var customAddress = [""]
    var session: WCSession?
    var isActive = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSlideMenuButton()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.requestWhenInUseAuthorization()
        startSession()
    }
    
    @IBAction func refreshUserInfo(_ sender: Any) {
        if isActive == true {
        sendToWatch()
        }
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
}
