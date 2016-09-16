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

class FirstViewController: UIViewController {
    

    @IBAction func onCreateButtonPressed(sender: UIButton) {
        performSegueWithIdentifier("toMap", sender: sender)
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
        if let alarmSound = self.setupAudioPlayerWithFile("alarm-clock-ticking", type:"wav") {
            self.alarmSound = alarmSound
        }
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

