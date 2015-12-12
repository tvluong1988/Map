//
//  AddressTableView.swift
//  Map
//
//  Created by Thinh Luong on 12/11/15.
//  Copyright © 2015 Thinh Luong. All rights reserved.
//

import UIKit
import MapKit

protocol AddressTableViewDelegate: class {
  func updateLocationAtIndex(index: Int, address: String, mapItem: MKMapItem)
}

class AddressTableView: UITableView {
  
  // MARK: Delegates
  weak var addressDelegate: AddressTableViewDelegate?
  
  // MARK: Lifecycle
  override init(frame: CGRect, style: UITableViewStyle) {
    super.init(frame: frame, style: style)
    
    delegate = self
    dataSource = self
    
    registerClass(UITableViewCell.self, forCellReuseIdentifier: "AddressCell")
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  // MARK: Properties
  var addresses: [String]!
  var placemarks: [CLPlacemark]!
  var senderTag: Int!
}

// MARK: UITableViewDelegate
extension AddressTableView: UITableViewDelegate {
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 50
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 80
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let label = UILabel()
    label.font = UIFont(name: "Verdana-Regular", size: 18)
    label.textAlignment = .Center
    label.text = "Did you mean..."
    label.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.75)
    
    return label
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let row = indexPath.row
    
    if row < addresses.count {
      let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: placemarks[row].location!.coordinate, addressDictionary: placemarks[row].addressDictionary as! [String: AnyObject]?))
      
      addressDelegate?.updateLocationAtIndex(senderTag, address: addresses[row], mapItem: mapItem)
    }
    
    removeFromSuperview()
  }
}

// MARK: UITableViewDataSource
extension AddressTableView: UITableViewDataSource {
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return addresses.count + 1
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier("AddressCell") as UITableViewCell!
    cell.textLabel?.numberOfLines = 3
    cell.textLabel?.font = UIFont(name: "Verdana-Regular", size: 11)
    
    if indexPath.row < addresses.count {
      cell.textLabel?.text = addresses[indexPath.row]
    } else {
      cell.textLabel?.text = "None of the above"
    }
    return cell
  }
}