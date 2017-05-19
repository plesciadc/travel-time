//
//  TravelData.swift
//  Travel Time
//
//  Created by Daniel Plescia on 3/7/17.
//  Copyright © 2017 Daniel Plescia. All rights reserved.
//
import Foundation

class GlobalTravelData {
    
    // Now Global.sharedGlobal is your singleton, no need to use nested or other classes
    static let sharedGlobalTravel = GlobalTravelData()
    
    var homeTime:String = ""
    var workTime:String = ""
    var customTime:String = ""
    
}
