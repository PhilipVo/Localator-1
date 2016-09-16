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
        print("here")
        if self.distance < 30 {
            alarmSound?.stop()
            alarmSound?.play()
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            timer?.invalidate()
            timer = NSTimer.scheduledTimerWithTimeInterval(2*distance/30.0, target: self, selector: #selector(loop), userInfo: nil, repeats: true)
            
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
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! Friend
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMapsWithLaunchOptions(launchOptions)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        distance = locations.last!.distanceFromLocation(friends[0].location)
        alertsLabel.text = String(distance)
        alertsLabel.backgroundColor = UIColor(red: 255/255.0, green: 0.0, blue: 0.0, alpha: CGFloat(1/distance))
//        if !isInitialized {
//            isInitialized = true
//            
//            let userLoction: CLLocation = locations[0]
//            let latitude = userLoction.coordinate.latitude
//            let longitude = userLoction.coordinate.longitude
//            let latDelta: CLLocationDegrees = 0.001
//            let lonDelta: CLLocationDegrees = 0.001
//            let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
//            let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
//            let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
//            mapView.setRegion(region, animated: true)
//            mapView.showsUserLocation = true
//        }
    }

}