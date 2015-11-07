//
//  HomeController.swift
//  Bankroll
//
//  Created by AD Mohanraj on 6/17/15.
//  Copyright (c) 2015 AD. All rights reserved.
//

import UIKit
import SWXMLHash
import CoreLocation

class HomeController: UITableViewController, NewPostViewControllerDelegate {
    
    @IBOutlet var segment: UISegmentedControl!
    @IBOutlet var navBar: UINavigationBar!

    
    var tblData : Array<Post>!
    var recData : Array<Post>!
    var treData : Array<Post>!
    
    //This method takes the data returned from the server and puts into an array of Post objects
    func extractPostsFromString(string : String, number : Int) -> [Post] {
        //The xml was encoded to make it URL safe, so now we decode it
        let xmlStr = string.stringByReplacingOccurrencesOfString("@", withString: "<", options:  NSStringCompareOptions.LiteralSearch, range: nil)
        
        println(xmlStr)
        var array = [Post]()
        
        //Parse the XML
        let parser = SWXMLHash.parse(xmlStr)
        
        //Loop through the XML and generate Post objects from the data
        for postNumber in 0...number-1 {
            var cPost = Post()
            cPost.postInformation = parser["Root"][String(format: "item%i", postNumber)]["postBody"].element?.text
            
            //Get latitude
            let lat = (parser["Root"][String(format: "item%i", postNumber)]["latitude"].element?.text as NSString?)?.doubleValue
            
            //Get longitude
            let long = (parser["Root"][String(format: "item%i", postNumber)]["longitude"].element?.text as NSString?)?.doubleValue
            
            //Set the Post instance variables
            cPost.postLocation = CLLocation(latitude: lat!, longitude: long!)
            cPost.timePosted = parser["Root"][String(format: "item%i", postNumber)]["timePosted"].element?.text
            cPost.isPublic = (parser["Root"][String(format: "item%i", postNumber)]["isPublic"].element?.text as NSString?)?.boolValue
            cPost.ranking = (parser["Root"][String(format: "item%i", postNumber)]["ranking"].element?.text as NSString?)?.integerValue
            
            //Get the path on the server to the image and the user info
            let imgPath = parser["Root"][String(format: "item%i", postNumber)]["imgPath"].element?.text as NSString!
            let userPath = parser["Root"][String(format: "item%i", postNumber)]["userPath"].element?.text as NSString!
            
            var param : Dictionary = ["path" : userPath]
            
            //Get user
            let pUser = User()
            pUser.username = userPath.substringWithRange(NSRange(location: 7, length: userPath.length-8))
            
            //Get the poster's profile picture
            request(.POST, "http://msgserver.esy.es/getProfilePic.php", parameters: param)
                .validate()
                .response { (request, response, data, error) in
                    pUser.profilePic = UIImage(data: data as NSData)
                    cPost.poster = pUser
                    self.tableView.reloadData()
            }
            
            param = ["path" : imgPath]
            
            //Get the post image
            request(.POST, "http://msgserver.esy.es/getImage.php", parameters: param)
                .validate()
                .response { (request, response, data, error) in
                    cPost.img = UIImage(data: data as NSData)
                    self.tableView.reloadData()
            }
            
            //Add the Post object to the array of all posts
            array.append(cPost)
        }
        
        return array
    }
    
    //Sorting function
    func recentSorter(this:Post, that:Post) -> Bool {
        return this.timePosted > that.timePosted
    }
    
    //Sorting function
    func trendingSorter(this:Post, that:Post) -> Bool {
        return this.ranking > that.ranking
    }
    
    //This method contacts the server to get all posts within the geographic range
    func getPosts(location: NSString, password : NSString) {
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
                
                request(.POST, "http://msgserver.esy.es/displayPosts.php", parameters: params)
                    .validate()
                    .response { (request, response, data2, error) in
                        //Parse the xml
                        var xml2 = NSString(data: data2 as NSData, encoding: NSUTF8StringEncoding)!
                        println(xml2)
                        let parser2 = SWXMLHash.parse(xml2)
                        let success2 = parser2["Root"]["Success"].element?.text
                        let posts = parser2["Root"]["Data"].element?.text!
                        let pNum = parser2["Root"]["Number"].element?.text!.toInt()
                        
                        if success2! == "Yes" && pNum >= 1 {
                            //Decode the server data
                            self.recData = self.extractPostsFromString(posts!, number: pNum!)
                            
                            //Sort the data before displaying
                            self.recData.sort(self.recentSorter)
                            self.treData = self.recData
                            self.treData.sort(self.trendingSorter)
                            self.tblData = self.recData
                        }
                        //Display data
                        self.tableView.reloadData()
                }
        }
    }

    func sendLocationData(lat : Double, long : Double) {
        //Formats the location data as XML using the custom XMLWriter class
        let xmlWriter : XMLWriter = XMLWriter()
        xmlWriter.addElementToGroup("Latitude", content: String(format: "%f", lat))
        xmlWriter.addElementToGroup("Longitude",content: String(format: "%f", long))
        xmlWriter.createElementThatEncapsulatesGroup("Root")
        
        //Get the posts within range from the server
        self.getPosts(xmlWriter.getXMLString(), password: Crypto.randomStringWithLength(200))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Initialize latitude and longitude values to 0
        var lat : Double = 0
        var long : Double = 0
        
        //Get the current latitude and longitude
        let locMgr = INTULocationManager.sharedInstance()
        locMgr.requestLocationWithDesiredAccuracy(INTULocationAccuracy.Room, timeout: 30.0, block: { (currentLocation : CLLocation!, achievedAccuracy : INTULocationAccuracy, status : INTULocationStatus) in
            if (status == INTULocationStatus.Success || status == INTULocationStatus.TimedOut) {
                // Request succeeded, meaning achievedAccuracy is at least the requested accuracy, and
                // currentLocation contains the device's current location.
                lat = currentLocation.coordinate.latitude
                long = currentLocation.coordinate.longitude
                
                //Sends location data to the server
                self.sendLocationData(lat, long: long)
            }
            else {
                // An error occurred, more info is available by looking at the specific status returned.
                println("Error: \(status)")
            }
        })
        
        recData = []
        treData = []
        
        tblData = recData
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tblData.count
    }
    
    override func tableView(tableView: (UITableView!), cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : PostCell = tableView.dequeueReusableCellWithIdentifier("PostCell") as PostCell
        let post : Post = tblData[indexPath.row]
        
        //Assign values to the components in the table view
        cell.user.text = post.poster?.username
        cell.time.text = post.timePosted
        cell.post.text = post.postInformation
        cell.profilePic.image = post.poster?.profilePic
        cell.postPic.image = post.img
        cell.rankLbl.text = String(post.ranking!)
        
        return cell
    }
    
    //Sets the height and color of each cell depending on the length of the post and the size of the image attached
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cell : PostCell = tableView.dequeueReusableCellWithIdentifier("PostCell") as PostCell
        let post : Post = tblData[indexPath.row]
                
        //Get all custom cell components
        let postLbl = cell.post
        let postPic : UIImageView = cell.postPic
        
        //Post lbl properties
        let PADDING : Float = 8
        let pString = post.postInformation as NSString?
        
        //Get size occupied by the text
        let textRect = pString?.boundingRectWithSize(CGSizeMake(CGFloat(self.tableView.frame.size.width - CGFloat(PADDING * 3.0)), CGFloat(1000)), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(14.0)], context: nil)
        
        //Individual height variables
        let postInfoHeight = 66 as CGFloat
        var postHeight = textRect?.size.height
        postHeight? += CGFloat(PADDING * 3)
        var imgHeight = 8 + postPic.frame.height as CGFloat
        
        /*if post.img == nil {
            postPic.removeFromSuperview()
            imgHeight = 0
        }*/
        
        //Change the autolayout constraints so it works properly
        return postInfoHeight + postHeight! + imgHeight
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayRecent() {
        tblData = recData
        self.tableView.reloadData()
        self.tableView.setContentOffset(CGPointMake(0, -64), animated:true)
    }
    
    func displayTrending() {
        tblData = treData
        self.tableView.reloadData()
        self.tableView.setContentOffset(CGPointMake(0, -64), animated:true)
    }
    
    @IBAction func switchView(sender: UISegmentedControl!) {
        switch segment.selectedSegmentIndex
        {
            case 0:
                displayRecent()
            case 1:
                displayTrending()
            default:
                break
        }
    }
    
    //Segue to the new post view
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "newPostSegue" {
            let navigationController : UINavigationController = segue.destinationViewController as UINavigationController
            let newPostViewController : NewPostViewController = navigationController.viewControllers[0] as NewPostViewController
            newPostViewController.delegate = self
        }
    }
    
    //Delegate methods
    func newPostViewControllerDidCancel(controller: NewPostViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func newPostViewControllerDidPost(controller: NewPostViewController, post : Post) {
        //Sort both arrays by time/ranking respectively
        recData.append(post)
        treData.append(post)
        
        tblData.append(post)
        self.tableView.reloadData()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
