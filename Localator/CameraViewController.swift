//
//  CameraViewController.swift
//  Localator
//
//  Created by Vanessa Bell on 9/22/16.
//  Copyright © 2016 Vanessa Bell. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    var captureSession = AVCaptureSession()
    var sessionOutput = AVCaptureStillImageOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    weak var cancelButtonDelegate: CancelButtonDelegate?
    
    @IBAction func cancelBarButtonPressed(sender: UIBarButtonItem) {
        cancelButtonDelegate?.cancelButtonPressedFrom(self)
    }
    
    @IBOutlet var cameraView: UIView!
    
    override func viewWillAppear(animated: Bool) {
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        for device in devices {
            if device.position == AVCaptureDevicePosition.Back {
                do{
                    let input = try AVCaptureDeviceInput(device: device as! AVCaptureDevice)
                    if captureSession.canAddInput(input){
                        captureSession.addInput(input)
                        sessionOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
                        
                        if captureSession.canAddOutput(sessionOutput){
                            captureSession.addOutput(sessionOutput)
                            captureSession.startRunning()
                            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                            previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
                            cameraView.layer.addSublayer(previewLayer)
                            previewLayer.position = CGPoint(x: self.cameraView.frame.width / 2, y: self.cameraView.frame.height / 2)
                            
                            previewLayer.bounds = cameraView.frame
                            previewLayer.frame = cameraView.bounds
                        }
                    }
                }
                catch{
                    print("Error")
                }
            }
        }
    }
    
    @IBAction func TakePhoto(sender: AnyObject) {
        print("photo button pressed")
        if let videoConnection = sessionOutput.connectionWithMediaType(AVMediaTypeVideo){
            sessionOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {
                buffer, error in
//                let image = UIImage(data: AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)!)!
//                let data = UIImagePNGRepresentation(image)
//                let base64 = data?.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
//                let decodedData = NSData(base64EncodedString: base64!, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)!
//                let backToImage = UIImage(data: decodedData)!
            })
        }
        
        // Flash the screen white and fade it out
        let aView = UIView(frame: self.view.frame)
        aView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(aView)
        
        UIView.animateWithDuration(1.3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            aView.alpha = 0.0
            }, completion: { (done) -> Void in
                aView.removeFromSuperview()
        })
    }
    
    
    
}