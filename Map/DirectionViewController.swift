//
//  DirectionViewController.swift
//  Map
//
//  Created by Thinh Luong on 12/11/15.
//  Copyright © 2015 Thinh Luong. All rights reserved.
//

import UIKit
import MapKit

/// Handle displaying directions on mapView and tableView.
class DirectionViewController: UIViewController {
  
  // MARK: Outlets
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var directionTableView: DirectionTableView!
  @IBOutlet weak var totalTimeLabel: UILabel!
  
  // MARK: Functions
  func displayDirections(directionArray: [(startingAddress: String, endingAddress: String, route: MKRoute)]) {
    directionTableView.directionArray = directionArray
    
    directionTableView.delegate = directionTableView
    directionTableView.dataSource = directionTableView
    
    directionTableView.reloadData()
  }
  
  func calculateSegmentDirections(index: Int, var time: NSTimeInterval, var routes: [MKRoute]) {
    let request = MKDirectionsRequest()
    request.source = validLocations[index].mapItem
    request.destination = validLocations[index + 1].mapItem
    
    request.requestsAlternateRoutes = true
    
    request.transportType = .Automobile
    
    let directions = MKDirections(request: request)
    directions.calculateDirectionsWithCompletionHandler {
      response, error in
      if let responseRoutes = response?.routes {
        let quickestRouteForSegment: MKRoute = responseRoutes.sort{$0.expectedTravelTime < $1.expectedTravelTime}[0]
        routes.append(quickestRouteForSegment)
        
        time += quickestRouteForSegment.expectedTravelTime
        
        if index + 2 < self.validLocations.count {
          self.calculateSegmentDirections(index + 1, time: time, routes: routes)
        } else {
          self.hideActivityIndicator()
          self.showRoutes(routes, time: time)
        }
        
      } else {
        self.showAlert("Directions not available.")
      }
    }
  }
  
  func showRoutes(routes: [MKRoute], time: NSTimeInterval) {
    var directions = [(startingAddress: String, endingAddress: String, route: MKRoute)]()
    for (index, route) in routes.enumerate() {
      plotPolyLine(route)
      
      directions.append((startingAddress: validLocations[index].address, endingAddress: validLocations[index + 1].address, route: route))
    }
    
    displayDirections(directions)
    
    totalTimeLabel.text = "Total: \(time.formatted())"
  }
  
  func plotPolyLine(route: MKRoute) {
    mapView.addOverlay(route.polyline)
    
    switch mapView.overlays.count {
    case 1:
      mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), animated: false)
    default:
      let polylineBoundingRect = MKMapRectUnion(mapView.visibleMapRect, route.polyline.boundingMapRect)
      mapView.setVisibleMapRect(polylineBoundingRect, edgePadding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), animated: false)
    }
  }
  
  func showAlert(message: String) {
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
    
    let okButton = UIAlertAction(title: "OK", style: .Cancel) {
      _ in
      self.navigationController?.popViewControllerAnimated(true)
    }
    
    alert.addAction(okButton)
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
  func showActivityIndicator() {
    activityIndicator = UIActivityIndicatorView(frame: UIScreen.mainScreen().bounds)
    activityIndicator?.activityIndicatorViewStyle = .WhiteLarge
    activityIndicator?.backgroundColor = view.backgroundColor
    activityIndicator?.startAnimating()
    view.addSubview(activityIndicator!)
  }
  
  func hideActivityIndicator() {
    if activityIndicator != nil {
      activityIndicator?.removeFromSuperview()
      activityIndicator = nil
    }
  }
  
  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
        
    showActivityIndicator()
    calculateSegmentDirections(0, time: 0, routes: [])
  }
  
  // MARK: Properties
  var validLocations: [(address: String, mapItem: MKMapItem)]!
  
  var activityIndicator: UIActivityIndicatorView?
  
}

// MARK: MKMapViewDelegate
extension DirectionViewController: MKMapViewDelegate {
  func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
    let polylineRenderer = MKPolylineRenderer(overlay: overlay)
    if overlay is MKPolyline {
      switch mapView.overlays.count {
      case 1:
        polylineRenderer.strokeColor = UIColor.blueColor().colorWithAlphaComponent(0.75)
      case 2:
        polylineRenderer.strokeColor = UIColor.greenColor().colorWithAlphaComponent(0.75)
      case 3:
        polylineRenderer.strokeColor = UIColor.redColor().colorWithAlphaComponent(0.75)
      default: break
      }
      
      polylineRenderer.lineWidth = 5
    }
    
    return polylineRenderer
  }
}

































