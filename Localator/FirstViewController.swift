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

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    


}

