//
//  NavigationColorSetter.swift
//  Bankroll
//
//  Created by AD Mohanraj on 10/18/15.
//  Copyright (c) 2015 AD. All rights reserved.
//

import UIKit

class NavigationColorSetter: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Set navigation bar color
        //self.navigationBar.barTintColor = UIColor(red: 1.0, green: 0.4, blue: 0.4, alpha:1.0)
        
        self.navigationBar.barTintColor = UIColor(red: 0.0, green: 0.6588, blue: 0.7765, alpha:1.0)
        self.navigationBar.translucent = false;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
