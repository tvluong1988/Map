//
//  LocationDataManager.swift
//  Map
//
//  Created by Thinh Luong on 12/12/15.
//  Copyright © 2015 Thinh Luong. All rights reserved.
//

import MapKit

class LocationDataManager {
  
  // MARK: Functions
  
  func updateLocationAtIndex(index: Int, address: String?, mapItem: MKMapItem?) {
    locations[index].address = address
    locations[index].mapItem = mapItem
  }
  
  func getValidLocations() -> [(address: String, mapItem: MKMapItem)] {
    var validLocations = [(address: String, mapItem: MKMapItem)]()
    
    for location in locations {
      if location.mapItem != nil {
        validLocations += [(address: location.address!, mapItem: location.mapItem!)]
      }
    }
    
    validLocations.append(validLocations.first!)
    
    return validLocations
  }
  
  func areInputsValid() -> Bool {
    if locations[0].mapItem == nil ||
      (locations[1].mapItem == nil && locations[2].mapItem == nil) {
        return false
    }
    
    return true
  }
  
  init() {
    for _ in 1...3 {
      locations += [(address: nil, mapItem: nil)]
    }
  }
  
  // MARK: Properties
  var locations = [(address: String?, mapItem: MKMapItem?)]()

}
