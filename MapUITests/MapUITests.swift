//
//  MapUITests.swift
//  MapUITests
//
//  Created by Thinh Luong on 12/11/15.
//  Copyright © 2015 Thinh Luong. All rights reserved.
//

import XCTest

class MapUITests: XCTestCase {
  
  // MARK: Tests
  func testViewControllerTitleExist() {
    XCTAssert(app.staticTexts["Trip"].exists)
  }
  
  func testRouteButton() {
    let startEndPointTextField = app.textFields["Start/End Point"]
    startEndPointTextField.tap()
    startEndPointTextField.buttons["Clear text"].tap()
    
    app.buttons["Route"].tap()
    app.alerts.element.buttons["OK"].tap()
    
    startEndPointTextField.tap()
    startEndPointTextField.typeText("Des Moines Iowa")
    
    app.buttons["StartEndEnter"].tap()
    app.tables.staticTexts["Des Moines, IA, United States"].tap()
    
    app.buttons["Route"].tap()
    app.alerts.element.buttons["OK"].tap()
    
    let destination1TextField = app.textFields["Stop #1"]
    destination1TextField.tap()
    destination1TextField.typeText("Rochester MN")
    
    app.buttons["Destination1Enter"].tap()
    app.tables.staticTexts["Rochester, MN, United States"].tap()
    
    app.buttons["Route"].tap()
    app.buttons["Trip"].tap()
    
    let destination2TextField = app.textFields["Stop #2 (optional)"]
    destination2TextField.tap()
    destination2TextField.typeText("New York City")
    
    app.buttons["Destination2Enter"].tap()
    app.tables.staticTexts["New York, NY, United States"].tap()
    
    app.buttons["Route"].tap()
    app.buttons["Trip"].tap()
    
    destination1TextField.tap()
    destination1TextField.buttons["Clear text"].tap()
    destination2TextField.tap()
    destination2TextField.buttons["Clear text"].tap()
    
    app.buttons["Route"].tap()
    app.alerts.element.buttons["OK"].tap()
  }
  
  func testUserInput() {
    
    let startEndPointTextField = app.textFields["Start/End Point"]
    startEndPointTextField.tap()
    startEndPointTextField.buttons["Clear text"].tap()
    startEndPointTextField.typeText("Des Moines Iowa")
    
    app.buttons["StartEndEnter"].tap()
    XCTAssert(app.tables.staticTexts["None of the above"].exists)
    app.tables.staticTexts["None of the above"].tap()
    
    var address = startEndPointTextField.value as! String
    XCTAssert(address == "Des Moines Iowa")
    XCTAssert(app.buttons["✓"].exists == false)
    
    
    app.buttons["StartEndEnter"].tap()
    app.tables.staticTexts["Des Moines, IA, United States"].tap()
    
    address = startEndPointTextField.value as! String
    XCTAssert(address == "Des Moines, IA, United States")
    
    XCTAssert(app.buttons["StartEndEnter"].selected)

  }
  
  func testDestinationSwap() {
    let destination1TextField = app.textFields["Stop #1"]
    let destination2TextField = app.textFields["Stop #2 (optional)"]
    
    destination1TextField.tap()
    destination1TextField.typeText("Des Moines Iowa")
    
    app.buttons["Destination1Enter"].tap()
    app.tables.staticTexts["Des Moines, IA, United States"].tap()
    
    app.buttons["↑↓"].tap()
    
    let address = destination2TextField.value as! String
    XCTAssert(address == "Des Moines, IA, United States")
    
    XCTAssert(app.buttons["Destination2Enter"].selected)
  }
  
  // MARK: Lifecycle
  override func setUp() {
    super.setUp()
    continueAfterFailure = false
    app.launch()
//    print(app.debugDescription)
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  // MARK: Properties
  let app = XCUIApplication()
  
}
