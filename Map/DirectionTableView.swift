//
//  DirectionTableView.swift
//  Map
//
//  Created by Thinh Luong on 12/11/15.
//  Copyright © 2015 Thinh Luong. All rights reserved.
//

import UIKit
import MapKit

/// DirectionTableView
class DirectionTableView: UITableView {
  
  
  // MARK: Properties
  
  /// Hold list of directions.
  var directionArray: [(startingAddress: String, endingAddress: String, route: MKRoute)]!
  
}

// MARK: UITableViewDataSource
extension DirectionTableView: UITableViewDataSource {
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return directionArray.count
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return directionArray[section].route.steps.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("DirectionCell") as UITableViewCell!
    cell.textLabel?.numberOfLines = 4
    cell.textLabel?.font = UIFont(name: "Verdana-Regular", size: 12)
    cell.userInteractionEnabled = false
    
    let steps = directionArray[indexPath.section].route.steps
    let step = steps[indexPath.row]
    let instructions = step.instructions
    let distance = step.distance.miles()
    
    cell.textLabel?.text = "\(indexPath.row + 1). \(instructions) - \(distance) miles"
    
    return cell
  }
}

// MARK: UITableViewDelegate
extension DirectionTableView: UITableViewDelegate {
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 60
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 80
  }
  
  func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 120
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let label = UILabel()
    label.font = UIFont(name: "Verdana-Regular", size: 14)
    label.numberOfLines = 5
    
    setLabelBackgroundColor(label, section: section)
    
    label.text = "Segment #\(section + 1)\n\nStarting point: \(directionArray[section].startingAddress)\n"
    
    return label
  }
  
  func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let label = UILabel()
    label.font = UIFont(name: "Verdana-Regular", size: 14)
    label.numberOfLines = 8
    
    setLabelBackgroundColor(label, section: section)
    
    let route = directionArray[section].route
    let time = route.expectedTravelTime.formatted()
    let distance = route.distance.miles()
    
    label.text = "Ending point: \(directionArray[section].endingAddress)\n\nDistance: \(distance) miles\n\nExpected trave time: \(time)"
    
    return label
  }
  
  private func setLabelBackgroundColor(label: UILabel, section: Int) {
    switch section {
    case 0:
      label.backgroundColor = UIColor.blueColor().colorWithAlphaComponent(0.25)
    case 1:
      label.backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.25)
    default:
      label.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.25)
    }
  }
}

extension NSTimeInterval {
  func formatted() -> String {
    let formatter = NSDateComponentsFormatter()
    formatter.unitsStyle = .Full
    formatter.allowedUnits = [NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second]
    
    return formatter.stringFromTimeInterval(self)!
  }
}

extension Float {
  func format(f: String) -> String {
    return NSString(format: "%\(f)f", self) as String
  }
}

extension CLLocationDistance {
  func miles() -> String {
    let miles = Float(self)/1609.344
    return miles.format(".2")
  }
}











































