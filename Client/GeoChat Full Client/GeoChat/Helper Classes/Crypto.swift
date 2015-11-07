//
//  Crypto.swift
//  Bankroll
//
//  Created by AD Mohanraj on 6/26/15.
//  Copyright (c) 2015 AD. All rights reserved.
//

import Foundation

//Convert this class to use native Swift strings rather than NSStrings
class Crypto {
    private let message : NSString!
    private let password : NSString!

    private let data : NSData!
    private let eData : NSData!
    private let eString : NSString!
    
    private var ePassword : NSString!
    private var publicKey : NSString!
    
    init(message: NSString, password: NSString) {
        self.message = message
        self.password = password
        
        //Encrypts the message with the password using AES256 symmetric encryption
        self.data = self.message.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        self.eData = ACEncryptor.encryptData(self.data, password: self.password, error: nil)
        self.eString = eData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(0))
    }
    
    func getEncryptedDataAsString() -> NSString {
        return self.eString
    }
    
    func getEncryptedData() -> NSData {
        return self.eData
    }
    
    func getEncryptedPassword() -> NSString {
        return self.ePassword
    }
    
    //Encrypts the password to the data using RSA asymmetric encryption
    func encryptPassword(publicKey : NSString) -> NSString {
        self.publicKey = publicKey
        self.ePassword = RSA.encryptString(self.password, publicKey: self.publicKey)
        return self.ePassword
    }
    
    class func randomStringWithLength (len : Int) -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        var randomString : NSMutableString = NSMutableString(capacity: len)
        
        for (var i=0; i < len; i++){
            var length = UInt32 (letters.length)
            var rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        
        return randomString
    }
}