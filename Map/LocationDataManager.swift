//
//  LocationDataManager.swift
//  Map
//
//  Created by Thinh Luong on 12/12/15.
//  Copyright © 2015 Thinh Luong. All rights reserved.
//

import MapKit

/// Holds location data from user inputs.
class LocationDataManager {
  
  // MARK: Functions
  
  /**
  Update the associated address and mapItem in locations at specified index.
  
  - Parameter index: Index of locations array to be updated.
  - Parameter address: New address.
  - Parameter mapItem: MapItem associated with the new address.
  
  */
  func updateLocationAtIndex(index: Int, address: String?, mapItem: MKMapItem?) {
    locations[index].address = address
    locations[index].mapItem = mapItem
  }
  
  /**
  Retrieve an array of valid locations for a round trip.
   
  - Returns: An array of tuples. Each tuple holds an address and mapItem.
   
  */
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
  
  /**
  Check to see if there enough location information to request directions for a round trip.
   
  - Returns: Boolean indicating sufficient location information.
  */
  func areInputsValid() -> Bool {
    if locations[0].mapItem == nil ||
      (locations[1].mapItem == nil && locations[2].mapItem == nil) {
        return false
    }
    
    return true
  }
  
  // MARK: Lifecycle
  
  /// Initializes an LocationDataManager with three empty locations.
  init() {
    for _ in 1...3 {
      locations += [(address: nil, mapItem: nil)]
    }
  }
  
  // MARK: Properties
  
  /// Holds locations from user inputs.
  var locations = [(address: String?, mapItem: MKMapItem?)]()

}
