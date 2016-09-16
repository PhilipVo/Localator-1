//
//  MapViewController.swift
//  Localator
//
//  Created by Vanessa Bell on 9/15/16.
//  Copyright © 2016 Vanessa Bell. All rights reserved.
//

import UIKit
import MapKit
import AVFoundation
import AudioToolbox

class MapViewController: UIViewController, FirstViewControllerDelegate {
    
    @IBOutlet weak var alertsLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    let regionRadius = 30.0
    
    var mapDelegate: MapViewControllerDelegate?
    
    var friends: [Friend] = []
    var monitoredRegions: Dictionary<String, NSDate> = [:]
    var distance = 100.0
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let alertController = UIAlertController(title: "Disclaimer", message:
            "Welcome", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default,handler: nil))
        
        // 1. status is not determined
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager.requestAlwaysAuthorization()
        }
            // 2. authorization were denied
        else if CLLocationManager.authorizationStatus() == .Denied {
            locationManager.requestAlwaysAuthorization()
        }
            // 3. we do have authorization
        else if CLLocationManager.authorizationStatus() == .AuthorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    var timer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // locationManage setup:
        locationManager.delegate = self;
        locationManager.distanceFilter = 1;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.pausesLocationUpdatesAutomatically = false
        
        // mapView setup:
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .Follow
        
        // Add friends to map:
        let friend = Friend(title: "Philip Vo", locationName: "Coding Dojo's Parking Lot",
                            coordinate: CLLocationCoordinate2D(latitude: 37.375449, longitude: -121.910541))
        friends.append(friend)
        
        setupData()
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(loop), userInfo: nil, repeats: true)

    }
    
    func firstViewControllerDelegate(controller: UIViewController, didFinishReceivingUpdate person: NSDictionary) {
        let friend = Friend(title: person["name"]! as! String, locationName: "NULL", coordinate: CLLocationCoordinate2D(latitude: person["latitude"] as! CLLocationDegrees, longitude: person["longitude"] as! CLLocationDegrees))
        
        for i in 0..<friends.count {
            if friends[i].title == friend.title {
                friends[i] = friend
                return
            }
        }
        
        friends.append(friend)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loop() {
        if self.distance < 30 {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            timer?.invalidate()
            timer = NSTimer.scheduledTimerWithTimeInterval(distance/30.0, target: self, selector: #selector(loop), userInfo: nil, repeats: true)
            
        }
    }
}

