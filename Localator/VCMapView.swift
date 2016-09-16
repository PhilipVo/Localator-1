//
//  VCMapView.swift
//  MapKitTutorial
//
//  Created by Philip on 9/15/16.
//  Copyright © 2016 Philip Vo. All rights reserved.
//

import MapKit
import CoreLocation
import AVFoundation
import AudioToolbox

extension MapViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    func setupData() {
        // 1. check if system can monitor regions
        if CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion.self) {
            
            for friend in friends {
                // 2. region data
                let title = friend.title
                let coordinate = friend.coordinate
                
                // 3. setup region
                let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: coordinate.latitude,
                    longitude: coordinate.longitude), radius: regionRadius, identifier: title!)
                locationManager.startMonitoringForRegion(region)
                
                // 4. setup annotation
                mapView.addAnnotation(friend)
                
                // 5. setup circle
                let circle = MKCircle(centerCoordinate: coordinate, radius: regionRadius)
                mapView.addOverlay(circle)
            }
        }
        else {
            print("System can't track regions")
        }
    }
    
    // 6. draw circle
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.strokeColor = UIColor.redColor()
        circleRenderer.lineWidth = 1.0
        return circleRenderer
    }
    
    // 1
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Friend {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView { // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            }
            view.pinTintColor = annotation.pinColor()
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! Friend
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMapsWithLaunchOptions(launchOptions)
    }
    
//    // 1. user enter region
//    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
//        alertsLabel.text = "Entered"
//        let alertController = UIAlertController(title: "Disclaimer", message:
//            "Hello, world!", preferredStyle: UIAlertControllerStyle.Alert)
//        alertController.addAction(UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default,handler: nil))
//        
//        self.presentViewController(alertController, animated: true, completion: nil)
//        
//        monitoredRegions[region.identifier] = NSDate()
//    }
//    
//    // 2. user exit region
//    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
//        alertsLabel.text = "Exited"
//        let alertController = UIAlertController(title: "Disclaimer", message:
//            "Hello, world!", preferredStyle: UIAlertControllerStyle.Alert)
//        alertController.addAction(UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default,handler: nil))
//        
//        self.presentViewController(alertController, animated: true, completion: nil)
//        
//        monitoredRegions.removeValueForKey(region.identifier)
//    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        distance = locations.last!.distanceFromLocation(friends[0].location)
        mapDelegate?.mapViewControllerDelegate(self, coordinate: locations.last!.coordinate)
        alertsLabel.text = String(distance)
        alertsLabel.backgroundColor = UIColor(red: 255/255.0, green: 0.0, blue: 0.0, alpha: CGFloat(1/distance))
    }

}