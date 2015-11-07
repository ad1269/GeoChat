//
//  LaunchPic.swift
//  Bankroll
//
//  Created by AD Mohanraj on 6/17/15.
//  Copyright (c) 2015 AD. All rights reserved.
//

import UIKit

class LaunchPic: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        performSegueWithIdentifier("launchPicSegue", sender: self)
        
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 0
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
