//
//  ViewController.swift
//  Map
//
//  Created by Thinh Luong on 12/11/15.
//  Copyright © 2015 Thinh Luong. All rights reserved.
//

import UIKit
import MapKit
//import CoreLocation


class ViewController: UIViewController {
  
  // MARK: Segues 
  override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
    if locationTuples[0].mapItem == nil ||
      (locationTuples[1].mapItem == nil && locationTuples[2].mapItem == nil) {
        showAlert("Please enter a valid starting and at least one destination.")
        return false
    }
    
    return true
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowDirectionViewController", let directionVC = segue.destinationViewController as? DirectionViewController {
      directionVC.validLocations = validLocations
    }
  }

  // MARK: Outlets
  @IBOutlet weak var startingAddressTextField: UITextField!
  @IBOutlet weak var destination1TextField: UITextField!
  @IBOutlet weak var destination2TextField: UITextField!
  
  @IBOutlet var enterButtons: [UIButton]!
  
  var textFields: [UITextField!] {
    return [startingAddressTextField, destination1TextField, destination2TextField]
  }
  
  // MARK: Actions
  @IBAction func addressEntered(sender: UIButton) {
    view.endEditing(true)
    
    let currentField = locationTuples[sender.tag].textField
    
    CLGeocoder().geocodeAddressString(currentField.text!) {
      placemarks, error in
      if let placemarks = placemarks {
        self.showAddressTable(placemarks, tag: sender.tag)
      } else {
        self.showAlert("Address not found...")
      }
    }
  }
  
  @IBAction func swapButtonPressed(sender: UIButton) {
    swap(&destination1TextField.text, &destination2TextField.text)
    swap(&locationTuples[1].mapItem, &locationTuples[2].mapItem)
    swap(&enterButtons.filter{$0.tag == 1}.first!.selected, &enterButtons.filter{$0.tag == 2}.first!.selected)
  }
  
  
  
  // MARK: Functions
  
  func showAlert(message: String) {
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
    let okButton = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
    alert.addAction(okButton)
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
  func formatAddressFromPlacemark(placemark: CLPlacemark) -> String {
    let strings = placemark.addressDictionary!["FormattedAddressLines"] as! [String]
    
    return strings.joinWithSeparator(", ")
  }
  
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
    
    locationTuples = [(startingAddressTextField, nil), (destination1TextField, nil), (destination2TextField, nil)]
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    navigationController?.navigationBarHidden = true
  }
  
  // MARK: Properties
  var locationManager: CLLocationManager!
  var locationTuples: [(textField: UITextField!, mapItem: MKMapItem!)]!
  
  var validLocations: [(address: String!, mapItem: MKMapItem!)]! {
    var validTuples = locationTuples.filter{$0.mapItem != nil}
    validTuples += [validTuples.first!]
    
    var resultTuples = [(address: String!, mapItem: MKMapItem!)]()
    for validTuple in validTuples {
      resultTuples.append((address: validTuple.textField.text, mapItem: validTuple.mapItem!))
    }
    
    return resultTuples
  }
}

// MARK: AddressTableViewDelegate 
extension ViewController: AddressTableViewDelegate {
  func updateButtonSelected(tag: Int) {
    enterButtons.filter{$0.tag == tag}.first!.selected = true
  }
  
  func updateTextFieldWithAddress(address: String, tag: Int) {
    textFields.filter{$0.tag == tag}.first!.text = address
  }
  
  func updateLocationTupleMapItem(mapItem: MKMapItem, tag: Int) {
    for (index, locationTuple) in locationTuples.enumerate() {
      if locationTuple.textField.tag == tag {
        locationTuples[index].mapItem = mapItem
        break
      }
    }
  }
}

// MARK: CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    CLGeocoder().reverseGeocodeLocation(locations.last!) {
      placemarks, error in
      if let placemarks = placemarks {
        let placemark = placemarks.first!
        
        self.locationTuples[0].mapItem = MKMapItem(placemark: MKPlacemark(coordinate: placemark.location!.coordinate, addressDictionary: placemark.addressDictionary as! [String: AnyObject]?))
        self.startingAddressTextField.text = self.formatAddressFromPlacemark(placemark)
        
        self.enterButtons.filter{$0.tag == 0}.first!.selected = true
      }
    }
  }
  
  func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    print(error)
  }
}

// MARK: UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    
    enterButtons.filter{$0.tag == textField.tag}.first!.selected = false
    locationTuples[textField.tag].mapItem = nil
    return true
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    view.endEditing(true)
    
    for textField in textFields {
      if textField.text!.isEmpty {
        enterButtons.filter{$0.tag == textField.tag}.first!.selected = false
      }
    }
    
    return true
  }
}































