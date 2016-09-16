import UIKit
import CoreLocation
import AVFoundation
import AudioToolbox
import MediaPlayer

class FirstViewController: UIViewController, MapViewControllerDelegate {
    
    let socket = SocketIOClient(socketURL: NSURL(string: "http://samuels-macbook-air-2.local:5000")!, config: [.ForcePolling(true), .ForceNew(true)])

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBAction func onCreateButtonPressed(sender: UIButton) {
        socket.emit("room_created", ["name": nameField.text!])
    }
    
    // MARK: audio 
    // TODO: force volume to highest level
    var audioPlayer = AVAudioPlayer()
    var isPlaying = false
    var alarmSound : AVAudioPlayer?
    
    
//    let volumeView = MPVolumeView()
//    if let view = volumeView.subviews.first as? UISlider{
//        view.value = 0.1 //---0 t0 1.0---
//    }
//
    @IBAction func onSoundButtonPressed(sender: UIButton) {
        if isPlaying == true {
            alarmSound?.stop()
            isPlaying = false
        } else {
            alarmSound?.play()
            isPlaying = true
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusLabel.hidden = true
        nameField.text = UIDevice.currentDevice().name
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(hideKeyboard))
        
        view.addGestureRecognizer(tap)
        
        if let alarmSound = self.setupAudioPlayerWithFile("alarm-clock-ticking", type:"wav") {
            self.alarmSound = alarmSound
        }
        
        socket.on("connect") { data, ack in
            NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(self.validateCon), userInfo: nil, repeats: true)
        }
        
        socket.on("disconnect") { data, ack in
            self.statusLabel.hidden = true
            print("Disconnected :(")
        }
        
        socket.on("response") { res, ack in
            if let error = res[0]["error"] {
                if (res[0].objectForKey("error") != nil) {
                    self.statusLabel.hidden = false
                    self.statusLabel.textColor = UIColor.redColor()
                    self.statusLabel.text = error as? String
                } else {
                    if let data = res[0] as? NSDictionary {
                        self.code = String(data["data"]!["code"]! as! Int)
                        self.performSegueWithIdentifier("roomSegue", sender: self)
                    }
                }
            }
        }
        
        socket.on("position") { res, ack in
            print(res)
            
            if let data = res[0] as? NSDictionary {
                let person = data["data"]!["person"] as! NSDictionary
                self.firstDelegate?.firstViewControllerDelegate(self, didFinishReceivingUpdate: person)
            }
        }
        
        socket.connect(timeoutAfter: 5, withTimeoutHandler: {
            self.statusLabel.hidden = false
            self.statusLabel.textColor = UIColor.redColor()
            self.statusLabel.text = "Connection failed :("
        })
    }
    
    func mapViewControllerDelegate(controller: UIViewController, coordinate: CLLocationCoordinate2D) {
        socket.emit("position", ["latitude": coordinate.latitude, "longitude": coordinate.longitude])
    }
    
    func validateCon() {
        print("Connection is \((socket.engine?.connected)! ? "valid" : "invalid")")
    }
    
    func hideKeyboard() {
        view.endEditing(true)
    }
    
    var code: String?
    
    var firstDelegate: FirstViewControllerDelegate?
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "roomSegue" {
            let navController = segue.destinationViewController as! UINavigationController
            let controller = navController.topViewController as! TabBarController
            (controller.viewControllers![0] as! MapViewController).mapDelegate = self
            firstDelegate = (controller.viewControllers![0] as! MapViewController)
            controller.code = code!
        }
    }
    
    @IBAction func onJoinButtonPressed(sender: UIButton) {
        let alert = UIAlertController(title: "Join a Room", message: "Enter a code in the box!", preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.placeholder = "Type a code..."
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            self.code = textField.text
            
            self.socket.emit("room_joined", ["name": self.nameField.text!, "code": self.code!])
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: flashlight
    // on/off capability
    var on: Bool = false
    
    @IBAction func testButtonPressed(sender: UIButton) {
        let avDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        // check if the device has torch
        if avDevice.hasTorch {
            // lock your device for configuration
            do {
                _ = try avDevice.lockForConfiguration()
            } catch {
                print("error")
            }
            
            // check if your torchMode is on or off. If on turns it off otherwise turns it on
            if on == true {
                avDevice.torchMode = AVCaptureTorchMode.Off
                on = false
            } else {
                // sets the torch intensity to 100%
                do {
                    _ = try avDevice.setTorchModeOnWithLevel(1.0)
                    on = true
                } catch {
                    print("error")
                }
                //    avDevice.setTorchModeOnWithLevel(1.0, error: nil)
            }
            // unlock your device
            avDevice.unlockForConfiguration()
        }
    }
    
    // MARK: vibration
    
    @IBAction func onVibrateButtonPressed(sender: UIButton) {
        for _ in 1...5 {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        sleep(1)
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

