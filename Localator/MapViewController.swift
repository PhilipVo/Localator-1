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
import MediaPlayer

class MapViewController: UIViewController, FirstViewControllerDelegate {
    
    @IBOutlet weak var alertsLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var delegate: MapViewControllerDelegate?
    
    var firstDelegate: MapViewControllerDelegate?
    
    let locationManager = CLLocationManager()
    let regionRadius = 30.0
    
    var friends = [Friend]()
    var monitoredRegions: Dictionary<String, NSDate> = [:]
    var distance = 100.0
    var isInitialized = false
    
    var audioPlayer = AVAudioPlayer()
    var alarmSound : AVAudioPlayer?
    var isPlaying = false
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let alertController = UIAlertController(title: "Disclaimer", message:
            "Welcome", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default, handler: nil))
        
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager.requestAlwaysAuthorization()
        } else if CLLocationManager.authorizationStatus() == .Denied {
            locationManager.requestAlwaysAuthorization()
        } else if CLLocationManager.authorizationStatus() == .AuthorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    var timer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = tabBarController?.viewControllers![1] as! FriendsViewController
        
        locationManager.delegate = self;
        locationManager.distanceFilter = 1;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.pausesLocationUpdatesAutomatically = false
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .Follow

        delegate?.mapViewControllerDelegate(self, didUpdateFriends: friends)
        
        if let alarmSound = self.setupAudioPlayerWithFile("beep", type:"wav") {
            self.alarmSound = alarmSound
        }
        
        setupData()
        timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(loop), userInfo: nil, repeats: true)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func firstViewControllerDelegate(controller: UIViewController, friendJoined friend: Friend) {
        print("Received friendJoined")
        friends.append(friend)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.setupData()
            self.delegate?.mapViewControllerDelegate(self, didUpdateFriends:  self.friends)
        })
    }
    
    func firstViewControllerDelegate(controller: UIViewController, positionUpdated person: NSDictionary) {
        print("Received positionUpdated")
        dispatch_async(dispatch_get_main_queue(), {
            for friend in self.friends {
                if friend.socketId == person["id"] as? String {
                    print("Found, updating location of \(person["id"])")
                    friend.coordinate = CLLocationCoordinate2D(latitude: person["latitude"] as! CLLocationDegrees, longitude: person["longitude"] as! CLLocationDegrees)
                    self.setupData()
                    break
                }
            }
        })
    }
    
    func firstViewControllerDelegate(controller: UIViewController, imageChanged person: NSDictionary) {
        dispatch_async(dispatch_get_main_queue(), {
            for friend in self.friends {
                if friend.socketId == person["id"] as? String {
                    let decodedData = NSData(base64EncodedString: person["image"] as! String, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)!
                    let backToImage = UIImage(data: decodedData)!
                    friend.imageView = UIImageView(image: backToImage)
                    break
                }
            }
        })
    }
}

