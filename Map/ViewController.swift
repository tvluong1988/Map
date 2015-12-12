//
//  ViewController.swift
//  Map
//
//  Created by Thinh Luong on 12/11/15.
//  Copyright © 2015 Thinh Luong. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
  
  // MARK: Segues
  override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
    if locationDataManager.areInputsValid() {
      return true
    }

    showAlert("Please enter a valid starting and at least one destination.")
    return false
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowDirectionViewController", let directionVC = segue.destinationViewController as? DirectionViewController {
      directionVC.validLocations = locationDataManager.getValidLocations()
    }
  }

  // MARK: Outlets
  @IBOutlet weak var startingAddressTextField: UITextField!
  @IBOutlet weak var destination1TextField: UITextField!
  @IBOutlet weak var destination2TextField: UITextField!
  
  @IBOutlet var enterButtons: [UIButton]!
  
  /// Array holding all textFields.
  var textFields: [UITextField!] {
    return [startingAddressTextField, destination1TextField, destination2TextField]
  }
  
  // MARK: Actions
  
  /**
  Generate placemarks associated with user input and display them in a tableview for user to verify.
  
  - Parameter sender: Enter button that the user pressed.
  
  */
  @IBAction func addressEntered(sender: UIButton) {
    view.endEditing(true)
    
    let currentField = textFields[sender.tag]
    
    CLGeocoder().geocodeAddressString(currentField.text!) {
      placemarks, error in
      if let placemarks = placemarks {
        self.showAddressTable(placemarks, tag: sender.tag)
      } else {
        self.showAlert("Address not found...")
      }
    }
  }
  
  /**
  Swap the contents of destination1 and destination2. TextFields, Buttons, and LocationDataManager are updated.
   
  - Parameter sender: Swap button that the user pressed.
   
  */
  @IBAction func swapButtonPressed(sender: UIButton) {
    swap(&destination1TextField.text, &destination2TextField.text)
    swap(&locationDataManager.locations[1].address, &locationDataManager.locations[2].address)
    swap(&locationDataManager.locations[1].mapItem, &locationDataManager.locations[2].mapItem)
    swap(&enterButtons.filter{$0.tag == 1}.first!.selected, &enterButtons.filter{$0.tag == 2}.first!.selected)
  }
  
  // MARK: Functions
  
  /**
  Create and show AlertView
  
  - Parameter message: Message to display to user.
  
  */
  func showAlert(message: String) {
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
    let okButton = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
    alert.addAction(okButton)
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
  /**
  Create a formatted string address from a placemark.
   
  - Parameter placemark: CLPlacemark.
   
  - Returns: Formatted address.
   
  */
  func formatAddressFromPlacemark(placemark: CLPlacemark) -> String {
    let strings = placemark.addressDictionary!["FormattedAddressLines"] as! [String]
    
    return strings.joinWithSeparator(", ")
  }
  
  /**
  Create and show an addressTableView to display placemarks for user to verify and select.
   
  - Parameter placemarks: An array of CLPlacemark.
  - Parameter tag: Tag for identifying which textField the user is currently selecting.
   
  */
  func showAddressTable(placemarks: [CLPlacemark], tag: Int) {
    let addressTableView = AddressTableView(frame: UIScreen.mainScreen().bounds, style: .Plain)
    addressTableView.addressDelegate = self
    addressTableView.placemarks = placemarks
    
    var addresses = [String]()
    for placemark in placemarks {
      addresses.append(formatAddressFromPlacemark(placemark))
    }
    
    addressTableView.addresses = addresses
    addressTableView.senderTag = tag
    view.addSubview(addressTableView)
  }
  
  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if locationManager == nil {
      locationManager = CLLocationManager()
      locationManager.delegate = self
      
      locationManager.requestWhenInUseAuthorization()
      
      if CLLocationManager.locationServicesEnabled() {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestLocation()
      }
    }
    
    
    if locationDataManager == nil {
      locationDataManager = LocationDataManager()
    }

  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
        
  }
  
  // MARK: Properties
  
  /// Help get location updates.
  var locationManager: CLLocationManager!
  
  /// Help organize location data.
  var locationDataManager: LocationDataManager!

}

// MARK: AddressTableViewDelegate 
extension ViewController: AddressTableViewDelegate {
  
  /**
   Update location with new address and mapItem.
   
   - Parameter index: Location index to be updated.
   - Parameter address: New address.
   - Parameter mapItem: MKMapItem associated with new address.
   
   */
  func updateLocationAtIndex(index: Int, address: String, mapItem: MKMapItem) {
    enterButtons.filter{$0.tag == index}.first!.selected = true
    textFields.filter{$0.tag == index}.first!.text = address
    locationDataManager.updateLocationAtIndex(index, address: address, mapItem: mapItem)

  }
}

// MARK: CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    CLGeocoder().reverseGeocodeLocation(locations.last!) {
      placemarks, error in
      if let placemarks = placemarks {
        let placemark = placemarks.first!
        
        let address = self.formatAddressFromPlacemark(placemark)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: placemark.location!.coordinate, addressDictionary: placemark.addressDictionary as! [String: AnyObject]?))
        
        self.startingAddressTextField.text = address

        self.locationDataManager.updateLocationAtIndex(0, address: address, mapItem: mapItem)
        
        self.enterButtons.filter{$0.tag == 0}.first!.selected = true
      }
    }
  }
  
  func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    print("Error with CLLocationManager: \(error)")
  }
}

// MARK: UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    view.endEditing(true)
    
    for textField in textFields {
      if textField.text!.isEmpty {
        enterButtons.filter{$0.tag == textField.tag}.first!.selected = false
        
      }
    }
    
    return true
  }
  
  func textFieldShouldClear(textField: UITextField) -> Bool {
    enterButtons.filter{$0.tag == textField.tag}.first!.selected = false
    locationDataManager.updateLocationAtIndex(textField.tag, address: nil, mapItem: nil)
    
    return true
  }
  
  func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
    enterButtons.filter{$0.tag == textField.tag}.first!.selected = false
    locationDataManager.updateLocationAtIndex(textField.tag, address: nil, mapItem: nil)
    
    return true
  }
}































