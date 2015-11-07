//
//  User.swift
//  Bankroll
//
//  Created by AD Mohanraj on 6/24/15.
//  Copyright (c) 2015 AD. All rights reserved.
//

import Foundation
import UIKit

class User {
    //Add more variables if needed
    var username : String!
    var profilePic : UIImage!
    
    func randomStringWithLength (len : Int) -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyz"
        
        var randomString : NSMutableString = NSMutableString(capacity: len)
        
        for (var i=0; i < len; i++){
            var length = UInt32 (letters.length)
            var rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        
        return randomString
    }
    
    func randomUsername() -> String {
        let a = String(randomStringWithLength(5))
        let b = String(Int(arc4random_uniform(999)+1))
        return a + b
    }
    
    init() {
        self.username = randomUsername()
        self.profilePic = UIImage(named: "profile.jpg")
    }
}