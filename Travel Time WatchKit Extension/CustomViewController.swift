//
//  CustomViewController.swift
//  Travel Time
//
//  Created by Daniel Plescia on 3/4/17.
//  Copyright © 2017 Daniel Plescia. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation

class CustomViewController: WKInterfaceController, CLLocationManagerDelegate {
    

    @IBAction func leftSwipe(_ sender: Any) {
        if pageNum == 1 {
            pageNum = 2
            titleLabel.setText("Travel Time to Custom 2:")
            dotsImage.setImageNamed("custom2")
            timeLabel.setText("\nLoading...")
            defaultsKey = "customAddress2"
            getTime()
        } else if pageNum == 2 {
            pageNum = 3
            titleLabel.setText("Travel Time to Custom 3:")
            dotsImage.setImageNamed("custom3")
            timeLabel.setText("\nLoading...")
            defaultsKey = "customAddress3"
            getTime()
        } else {
        }
    }
    
    @IBAction func rightSwipe(_ sender: Any) {
        if pageNum == 1 {
        } else if pageNum == 2 {
            pageNum = 1
            titleLabel.setText("Travel Time to Custom 1:")
            dotsImage.setImageNamed("custom1")
            timeLabel.setText("\nLoading...")
            defaultsKey = "customAddress1"
            getTime()
        } else {
            pageNum = 2
            titleLabel.setText("Travel Time to Custom 2:")
            dotsImage.setImageNamed("custom2")
            timeLabel.setText("\nLoading...")
            defaultsKey = "customAddress2"
            getTime()
        }
    }
    
    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var timeLabel: WKInterfaceLabel!
    @IBOutlet var dotsImage: WKInterfaceImage!
    
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation = CLLocation()
    var pageNum = 1
    var defaultsKey = "customAddress1"
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        if let newContext = context {
            currentLocation = newContext as! CLLocation
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        timeLabel.setText("\nLoading...")
        getTime()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func getTime() {
        let rawAddress = UserDefaults.standard.value(forKey: defaultsKey) as! String
        let formattedAddress = rawAddress.replacingOccurrences(of: " ", with: "+")
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=" + "\(currentLocation.coordinate.latitude)" + "," + "\(currentLocation.coordinate.longitude)" + "&destination=" + formattedAddress + "&key=AIzaSyCM1YKymuB5ePN5-uX0KOtPGgae5tYSW0w&alternatives=true&departure_time=now")
        var dict = Dictionary<String, Any>()
        var newDict = NSArray()
        var finalArray = NSDictionary()
        var legs = NSArray()
        var legs2 = NSDictionary()
        var duration = NSDictionary()
        var time = ""
        var roads = ""
        var summaries:Array<String> = []
        var roadsList:Array<String> = []
        var summaryText = ""
        
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard error == nil else {
                print(error)
                self.timeLabel.setText("\nNo Routes Found.\nPlease Check Your Connection.")
                return
            }
            guard let data = data else {
                print("Data is empty")
                self.timeLabel.setText("\nNo Routes Found.\nAddress Format Incorrect.")
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            dict = json as! Dictionary
            newDict = dict["routes"] as! NSArray
            
            // Check for errors
            if newDict.count < 1 {
                self.timeLabel.setText("\nNo Routes Found.\nAddress Format Incorrect.")
            }
            else {
            
            for i in 0...newDict.count - 1
            {
                finalArray = newDict[i] as! NSDictionary
                legs = finalArray["legs"] as! NSArray
                legs2 = legs[0] as! NSDictionary
                duration = legs2["duration_in_traffic"] as! NSDictionary
                time = duration["text"] as! String
                roads = finalArray["summary"] as! String
                summaries.append(time + " via " + roads)
                if !(roadsList.contains(roads)) {
                    roadsList.append(roads)
                    if (i > 0) {
                        summaryText.append("\n" + summaries[i])
                    }else {
                        summaryText.append(summaries[i])
                    }
                }
            }
            self.timeLabel.setText(summaryText)
            WKInterfaceDevice.current().play(.click)
        }
    }
        
        task.resume()
    }
}
