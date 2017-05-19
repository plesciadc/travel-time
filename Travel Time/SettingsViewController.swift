//
//  SettingsViewController.swift
//  Travel Time
//
//  Created by Daniel Plescia on 2/28/17.
//  Copyright © 2017 Daniel Plescia. All rights reserved.
//

import UIKit
import CoreLocation
import WatchConnectivity

class SettingsViewController: BaseViewController, CLLocationManagerDelegate, WCSessionDelegate, UITextFieldDelegate {
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    var session: WCSession?
    var isActive = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSlideMenuButton()
        //self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.requestWhenInUseAuthorization()
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
    

    func sendToWatch() {
        
        /*
         let applicationDict = ["homeAddress": homeAddress, "workAddress": workAddress, "customAddress1": customAddress1, "customAddress2": customAddress2, "customAddress3": customAddress3]
        session?.transferUserInfo(applicationDict)
         */
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        sendToWatch()
        return true
    }
    
}
