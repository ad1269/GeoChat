//
//  NewPostViewController.swift
//  Bankroll
//
//  Created by AD Mohanraj on 6/25/15.
//  Copyright (c) 2015 AD. All rights reserved.
//

import Foundation
import UIKit
import SWXMLHash
import MobileCoreServices

protocol NewPostViewControllerDelegate {
    func newPostViewControllerDidCancel(controller : NewPostViewController)
    func newPostViewControllerDidPost(controller : NewPostViewController, post : Post)
}

class NewPostViewController: UITableViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var delegate : NewPostViewControllerDelegate?
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var privacyLabel: UILabel!
    
    @IBOutlet weak var heightConstraint : NSLayoutConstraint!
    var handler : GrowingTextViewHandler!
    var numberOfLines = 2

    var imgString : NSString = ""
    var lat : Double!
    var long : Double!
    
    //Called when the view loads
    override func viewDidLoad() {
        //Set the text box parameters
        postTextView.delegate = self
        handler = GrowingTextViewHandler(textView: postTextView, withHeightConstraint: heightConstraint)
        handler.updateMinimumNumberOfLines(1, andMaximumNumberOfLine: numberOfLines)
        
        //Get location
        let locMgr = INTULocationManager.sharedInstance()
        locMgr.requestLocationWithDesiredAccuracy(INTULocationAccuracy.Room, timeout: 30.0, block: { (currentLocation : CLLocation!, achievedAccuracy : INTULocationAccuracy, status : INTULocationStatus) in
            if (status == INTULocationStatus.Success || status == INTULocationStatus.TimedOut) {
                // Request succeeded, meaning achievedAccuracy is at least the requested accuracy, and
                // currentLocation contains the device's current location.
                self.lat = currentLocation.coordinate.latitude
                self.long = currentLocation.coordinate.longitude
            }
            else {
                // An error occurred, more info is available by looking at the specific status returned.
                println("Error: \(status)")
            }
        })
    }
    
    //Update the size of the text box to grow with the amount of text entered
    func textViewDidChange(textView: UITextView) {
        let newLine = handler.resizeTextViewWithAnimation(true)
        if newLine && numberOfLines != 23 {
            numberOfLines++
            handler.updateMinimumNumberOfLines(1, andMaximumNumberOfLine: numberOfLines)
        }
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    //Go back to viewing posts
    @IBAction func cancel(sender : AnyObject) {
        self.delegate?.newPostViewControllerDidCancel(self)
    }
    
    func createPosts(location: NSString, password : NSString) {
        let userKey = Crypto.randomStringWithLength(266) as String
        let param : Dictionary = ["key" : userKey]
        
        request(.POST, "http://msgserver.esy.es/OpenAuthenticationSession.php", parameters: param)
            .validate()
            .response { (req, response, data, error) in
                //Parse the xml
                var xml = NSString(data: data as NSData, encoding: NSUTF8StringEncoding)!
                println(xml)
                let parser = SWXMLHash.parse(xml)
                let success = parser["Root"]["Success"].element?.text
                
                //Encrypt data with a password and encrypt the password
                let a : Crypto = Crypto(message: location, password: password)
                
                //Specify parameters to send
                let params : Dictionary = ["data" : a.getEncryptedDataAsString(), "password" : a.encryptPassword(parser["Root"]["Key"].element?.text as NSString!), "uk" : userKey]
                
                request(.POST, "http://msgserver.esy.es/createPost.php", parameters: params)
                    .validate()
                    .response { (request, response, data2, error) in
                        //Parse the xml
                        var xml2 = NSString(data: data2 as NSData, encoding: NSUTF8StringEncoding)!
                        println(xml2)
                        let parser2 = SWXMLHash.parse(xml2)
                        let success2 = parser2["Root"]["Success"].element?.text
                        
                        if success2! == "Yes" {
                            //Go back to posts
                            self.delegate?.newPostViewControllerDidCancel(self)
                        }
                        else {
                            //Show error message
                            let alert = UIAlertView()
                            alert.title = "Post Error"
                            alert.message = "Could not connect to server. This may be due to poor internet connection. Please try again later."
                            alert.addButtonWithTitle("Okay")
                            alert.show()
                        }
                }
        }
    }
    
    //Called when the Post button is pressed
    @IBAction func post(sender : AnyObject) {
        var newPost = Post()
        newPost.postInformation = postTextView.text
        let xmlWriter : XMLWriter = XMLWriter()
        
        //Populate XML
        xmlWriter.addElementToGroup("PostBody", content: postTextView.text)
        xmlWriter.addElementToGroup("ImgString",content: imgString)
        xmlWriter.addElementToGroup("Latitude",content: NSString(format:"%f", lat))
        xmlWriter.addElementToGroup("Longitude",content: NSString(format:"%f", long))
        
        //Get current user
        xmlWriter.addElementToGroup("UserPath",content: "/Users/ad/")
        
        //Default value is public
        xmlWriter.addElementToGroup("IsPublic",content: "1")
        
        //Get current time
        let dayTimePeriodFormatter = NSDateFormatter()
        dayTimePeriodFormatter.dateFormat = "H:mm"
        xmlWriter.addElementToGroup("TimePosted",content: dayTimePeriodFormatter.stringFromDate(NSDate()))
        
        xmlWriter.createElementThatEncapsulatesGroup("Root")
        
        //Sends the created post to the server
        self.createPosts(xmlWriter.getXMLString(), password: (postTextView.text as NSString).substringWithRange(NSRange(location: 0, length: 5)))
    }
    
    //This method defines the actions to be taken when the cells are selected
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            self.postTextView.becomeFirstResponder()
        }
        else if indexPath.section == 1 {
            
            var imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            imagePickerController.allowsEditing = false
            self.presentViewController(imagePickerController, animated: true, completion: nil)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return self.postTextView.frame.height + 8
        }
        return 44
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        var data = UIImagePNGRepresentation(image)
        imgString = data.base64EncodedStringWithOptions(.allZeros)
    }
}