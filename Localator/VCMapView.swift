//
//  VCMapView.swift
//  MapKitTutorial
//
//  Created by Philip on 9/15/16.
//  Copyright © 2016 Philip Vo. All rights reserved.
//

import MapKit
import AVFoundation
import AudioToolbox

extension MapViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    
    func loop() {
        if self.distance < 30 {
            UIView.animateWithDuration(distance/60.0, delay: 0.0, options: UIViewAnimationOptions.ShowHideTransitionViews, animations: {
                
                if self.alertsLabel.alpha == 0.0 {
                    self.alertsLabel.alpha = 1.0
                } else {
                    self.alertsLabel.alpha = 0.3
                }
            }, completion: nil)
            
            alarmSound?.stop()
            alarmSound?.play()
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            timer?.invalidate()
            timer = NSTimer.scheduledTimerWithTimeInterval(2*distance/30.0, target: self, selector: #selector(loop), userInfo: nil, repeats: true)
        }
        else {
            self.alertsLabel.alpha = 1.0
            self.alertsLabel.backgroundColor = UIColor.blackColor()
        }
    }
    
    func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer?  {
        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        let url = NSURL.fileURLWithPath(path!)
        var audioPlayer:AVAudioPlayer?
        
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
        } catch {
            print("Player not available")
        }
        
        return audioPlayer
    }
    
    func setupData() {
        // 1. check if system can monitor regions
        if CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion.self) {
            for i in 0..<friends.count {
                let friend = friends[i]
                let title = friend.title
                let coordinate = friend.coordinate
                
                let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: coordinate.latitude,
                    longitude: coordinate.longitude), radius: regionRadius, identifier: title!)
                locationManager.startMonitoringForRegion(region)
                
                if let unwrappedOverlay = friend.overlay {
                    mapView.removeOverlay(unwrappedOverlay)
                }
                
                let clone = friend.clone()
                print(clone)
                mapView.addAnnotation(clone)
                mapView.removeAnnotation(friend)
                friends[i] = clone
                mapView.addAnnotation(clone)
                
                // 5. setup circle
                let circle = MKCircle(centerCoordinate: coordinate, radius: regionRadius)
                mapView.addOverlay(circle)
                clone.overlay = circle;
            }
        }
        else {
            print("System can't track regions")
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.strokeColor = UIColor.redColor()
        circleRenderer.lineWidth = 1.0
        return circleRenderer
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Friend {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
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
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! Friend
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMapsWithLaunchOptions(launchOptions)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let friend = friends.first {
            distance = locations.last!.distanceFromLocation(friend.location)
            alertsLabel.text = "Distance: " + String(Int(distance)) + " (meters)"
            if distance < 30 {
                self.alertsLabel.backgroundColor = UIColor.redColor()
            } else {
                self.alertsLabel.backgroundColor = UIColor.blackColor()
                
            }
        }
        
        firstDelegate?.mapViewControllerDelegate(self, didUpdateLocation: locations.last!.coordinate)
    }
    
    static func generateRandomColor() -> UIColor {
        let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
        let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
        let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
}