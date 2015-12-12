//
//  MapTests.swift
//  MapTests
//
//  Created by Thinh Luong on 12/11/15.
//  Copyright © 2015 Thinh Luong. All rights reserved.
//

import XCTest
import MapKit
@testable import Map

class MapTests: XCTestCase {
  
  // MARK: Tests
  func testUpdatingNewLocation() {
    
    let index = 0
    
    var location = viewcontroller.locationDataManager.locations[index]
    
    XCTAssert(location.address == nil)
    XCTAssert(location.mapItem == nil)
    
    viewcontroller.locationDataManager.updateLocationAtIndex(index, address: testAddress, mapItem: testMapItem)
    
    location = viewcontroller.locationDataManager.locations[index]
    XCTAssert(location.address != nil)
    XCTAssert(location.mapItem != nil)
  }
  
  func testGetValidLocations() {
    for index in 0..<2 {
      viewcontroller.locationDataManager.updateLocationAtIndex(index, address: testAddress, mapItem: testMapItem)
    }
    
    var validLocations = viewcontroller.locationDataManager.getValidLocations()
    
    XCTAssert(validLocations.count == 3)
    
    viewcontroller.locationDataManager.updateLocationAtIndex(2, address: testAddress, mapItem: testMapItem)

    validLocations = viewcontroller.locationDataManager.getValidLocations()
    
    XCTAssert(validLocations.count == 4)
    
  }
  
  func testAreInputsValid() {
    let locationDataManager = viewcontroller.locationDataManager
    
    XCTAssert(locationDataManager.areInputsValid() == false)
    
    locationDataManager.updateLocationAtIndex(0, address: testAddress, mapItem: testMapItem)
    
    XCTAssert(locationDataManager.areInputsValid() == false)
    
    locationDataManager.updateLocationAtIndex(1, address: testAddress, mapItem: testMapItem)
    
    XCTAssert(locationDataManager.areInputsValid() == true)
    
    locationDataManager.updateLocationAtIndex(2, address: testAddress, mapItem: testMapItem)
    
    XCTAssert(locationDataManager.areInputsValid() == true)
    
    locationDataManager.updateLocationAtIndex(0, address: nil, mapItem: nil)
    
    XCTAssert(locationDataManager.areInputsValid() == false)
    
  }
  
  // MARK: Lifecycle
  override func setUp() {
    super.setUp()
    
    viewcontroller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ViewController") as! ViewController
    viewcontroller.viewDidLoad()
    directionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("DirectionViewController") as! DirectionViewController
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  // MARK: Properties
  var viewcontroller: ViewController!
  var directionViewController: DirectionViewController!
  let testAddress = "testAddress"
  let testMapItem = MKMapItem()
}
