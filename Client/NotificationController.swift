//
//  Notification Controller.swift
//  Bankroll
//
//  Created by AD Mohanraj on 6/17/15.
//  Copyright (c) 2015 AD. All rights reserved.
//

import UIKit

class NotificationController: UIViewController {
    
    @IBOutlet var segment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayYou() {
        
    }
    
    func displayFriends() {
        
    }
    
    @IBAction func switchView(sender: UISegmentedControl!) {
        switch segment.selectedSegmentIndex
        {
        case 0:
            displayFriends()
        case 1:
            displayYou()
        default:
            break
        }
    }
    
}
