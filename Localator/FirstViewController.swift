//
//  FirstViewController.swift
//  Localator
//
//  Created by Vanessa Bell on 9/15/16.
//  Copyright © 2016 Vanessa Bell. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox
import MediaPlayer
import CoreLocation

class FirstViewController: UIViewController, CancelButtonDelegate, MapViewControllerDelegate {
    let socket = SocketIOClient(socketURL: NSURL(string: "http://samuels-macbook-air-2.local:5000")!, config: [.ForcePolling(true), .ForceNew(true)])
    
    var window: UIWindow?
    var code: String?
    var friends: [NSDictionary]?
    var delegate: FirstViewControllerDelegate?
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBAction func onCreateButtonPressed(sender: UIButton) {
//        performSegueWithIdentifier("mainSegue", sender: sender)
        socket.emit("room_created", ["name": nameField.text!])
    }
    
    @IBAction func onJoinButtonPressed(sender: UIButton) {
        let alert = UIAlertController(title: "Join a Room", message: "Enter a code in the box!", preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.placeholder = "Type a code..."
        })
        
        //Handler for actions
        let actionAndDismiss = {
            (action: String?) -> ((UIAlertAction!) -> ()) in
            return {
                _ in
                self.window?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            self.code = textField.text
            
            self.socket.emit("room_joined", ["name": self.nameField.text!, "code": self.code!])
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: actionAndDismiss(nil)))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: delegation
    func cancelButtonPressedFrom(controller: UIViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.text = UIDevice.currentDevice().name
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tap)
        
        socket.on("connect") { data, ack in
            print("CONNECTED TO THE SERVER")
//            NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(self.validateCon), userInfo: nil, repeats: true)
        }
        
        socket.on("disconnect") { data, ack in
            print("Disconnected :(")
        }
        
        socket.on("response") { res, ack in
            if let error = res[0]["error"] {
                if (res[0].objectForKey("error") != nil) {
                    print(error)
                } else {
                    if let data = res[0]["data"] as? NSDictionary {
                        self.code = String(data["code"]! as! Int)
                        
                        if let people = data["people"] {
                            self.friends = people as? [NSDictionary]
                        }
                        
                        self.performSegueWithIdentifier("mainSegue", sender: self)
                    }
                }
            }
        }
        
        socket.on("room_joined") { res, ack in
            if let data = res[0]["data"] {
                if let person = data!["person"] {
                    let friend = Friend(socketId: person!["id"] as! String, title: person!["name"] as! String, locationName: "No idea", coordinate: CLLocationCoordinate2D(latitude: 37.375449, longitude: -121.910541))
                    self.delegate?.firstViewControllerDelegate(self, friendJoined: friend)
                }
            }
        }
        
        socket.on("position") { res, ack in
            print("Received position data \(res)")
            
            if let data = res[0] as? NSDictionary {
                let person = data["data"]!["person"] as! NSDictionary
                
                if (person["id"] as! String) != self.socket.engine?.sid {
                    self.delegate?.firstViewControllerDelegate(self, positionUpdated: person)
                }
            }
        }
        
        socket.connect(timeoutAfter: 5, withTimeoutHandler: {
            print("Connection failed :(")
        })
        
        if let alarmSound = self.setupAudioPlayerWithFile("alarm-clock-ticking", type:"wav") {
            self.alarmSound = alarmSound
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "mainSegue" {
            let navController = segue.destinationViewController as! UINavigationController
            let controller = navController.topViewController as! TabBarController
            controller.code = code!
            let mapViewController = controller.viewControllers![0] as! MapViewController
            delegate = mapViewController
            mapViewController.firstDelegate = self
            
            if let unwrappedFriends = friends {
                for person in unwrappedFriends {
                    let friend = Friend(socketId: person["id"] as! String, title: person["name"] as! String, locationName: "No idea", coordinate: CLLocationCoordinate2D(latitude: 37.375449, longitude: -121.910541))
                    delegate?.firstViewControllerDelegate(self, friendJoined: friend)
                }
            }
        }
        
        if segue.identifier == "cameraSegue" {
            let navController = segue.destinationViewController as! UINavigationController
            let controller = navController.topViewController as! CameraViewController
            controller.cancelButtonDelegate = self
        }
    }
    
    func validateCon() {
        print("Connection is \((socket.engine?.connected)! ? "valid" : "invalid")")
    }
    
    func hideKeyboard() {
        view.endEditing(true)
    }
    
    
    // MARK: audio
    var audioPlayer = AVAudioPlayer()
    var isPlaying = false
    var alarmSound : AVAudioPlayer?
    
    
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapViewControllerDelegate(controller: UIViewController, didUpdateFriends friends: [Friend]) {}
    
    func mapViewControllerDelegate(controller: UIViewController, didUpdateLocation coordinate: CLLocationCoordinate2D) {
        print("You moved, location sent to server.")
        socket.emit("position", ["latitude": coordinate.latitude, "longitude": coordinate.longitude])
    }
}

