//
//  PictureController.swift
//  Bankroll
//
//  Created by AD Mohanraj on 6/17/15.
//  Copyright (c) 2015 AD. All rights reserved.
//

import UIKit
import AVFoundation
import CameraManager

class PictureController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var previewView: UIView!
    var img : UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CameraManager.sharedInstance.addPreviewLayerToView(previewView)
        CameraManager.sharedInstance.cameraDevice = .Back
        CameraManager.sharedInstance.cameraOutputMode = .StillImage

        CameraManager.sharedInstance.cameraOutputQuality = .High
        
        CameraManager.sharedInstance.flashMode = .Auto
        CameraManager.sharedInstance.writeFilesToPhoneLibrary = true
        CameraManager.sharedInstance.showAccessPermissionPopupAutomatically = false
    }
    
    @IBAction func didPressTakePhoto(sender: AnyObject) {
        CameraManager.sharedInstance.capturePictureWithCompletition({ (image, error) -> Void in
            self.img = image
        })
    }
    
    @IBAction func cancel(sender: UIButton) {
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    @IBAction func choosePhoto(sender: UIButton) {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        
        presentViewController(picker, animated: true, completion: nil)
        
    }
}