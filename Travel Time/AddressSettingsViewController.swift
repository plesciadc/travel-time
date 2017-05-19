//
//  AddressSettingsViewController.swift
//  Travel Time
//
//  Created by Daniel Plescia on 2/28/17.
//  Copyright © 2017 Daniel Plescia. All rights reserved.
//

import UIKit
import CoreLocation
import WatchConnectivity

class AddressSettingsViewController: UITableViewController, CLLocationManagerDelegate, WCSessionDelegate, UITextFieldDelegate {

    @IBOutlet weak var homeAddressField: UITextField!
    @IBOutlet weak var workAddressField: UITextField!
    @IBOutlet weak var customAddressField2: UITextField!
    @IBOutlet weak var customAddressField3: UITextField!
    @IBOutlet weak var customAddressField1: UITextField!
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    var homeAddress = UserDefaults.standard.value(forKey: "homeAddress")
    var workAddress = UserDefaults.standard.value(forKey: "workAddress")
    var customAddress1 = UserDefaults.standard.value(forKey: "customAddress1")
    var customAddress2 = UserDefaults.standard.value(forKey: "customAddress2")
    var customAddress3 = UserDefaults.standard.value(forKey: "customAddress3")
    var session: WCSession?
    var isActive = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadTextBoxes()
        //self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.requestWhenInUseAuthorization()
        startSession()
    }
    
    @IBAction func closeClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
    
    func loadTextBoxes() {
        if UserDefaults.standard.value(forKey: "homeAddress") != nil {
            let homeAddress = UserDefaults.standard.value(forKey: "homeAddress") as! Array<String>
            homeAddressField.text = homeAddress[0]
        }
        if UserDefaults.standard.value(forKey: "workAddress") != nil {
            let workAddress = UserDefaults.standard.value(forKey: "workAddress") as! Array<String>
            workAddressField.text = workAddress[0]
        }
        if UserDefaults.standard.value(forKey: "customAddress1") != nil {
            let customAddress1 = UserDefaults.standard.value(forKey: "customAddress1") as! Array<String>
            customAddressField1.text = customAddress1[0]
        }
        if UserDefaults.standard.value(forKey: "customAddress2") != nil {
            let customAddress2 = UserDefaults.standard.value(forKey: "customAddress2") as! Array<String>
            customAddressField2.text = customAddress2[0]
        }
        if UserDefaults.standard.value(forKey: "customAddress3") != nil {
            let customAddress3 = UserDefaults.standard.value(forKey: "customAddress3") as! Array<String>
            customAddressField3.text = customAddress3[0]
        }
        
    }
    
    func sendToWatch() {
        homeAddress = [homeAddressField.text!]
        workAddress = [workAddressField.text!]
        customAddress1 = [customAddressField1.text!]
        customAddress2 = [customAddressField2.text!]
        customAddress3 = [customAddressField3.text!]
        
        UserDefaults.standard.setValue(homeAddress, forKey: "homeAddress")
        UserDefaults.standard.setValue(workAddress, forKey: "workAddress")
        UserDefaults.standard.setValue(customAddress1, forKey: "customAddress1")
        UserDefaults.standard.setValue(customAddress2, forKey: "customAddress2")
        UserDefaults.standard.setValue(customAddress3, forKey: "customAddress3")
        
        let applicationDict = ["homeAddress": homeAddress, "workAddress": workAddress, "customAddress1": customAddress1, "customAddress2": customAddress2, "customAddress3": customAddress3]
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        sendToWatch()
        return true
    }
    
}
