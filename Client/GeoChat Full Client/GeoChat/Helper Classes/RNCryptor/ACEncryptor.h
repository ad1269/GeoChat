//
//  ACEncryptor.h
//  NetworkTest
//
//  Created by AD Mohanraj on 6/22/15.
//  Copyright (c) 2015 AD. All rights reserved.
//

#import "RNEncryptor.h"

@interface ACEncryptor : RNEncryptor

+ (NSData *)encryptData:(NSData *)data password:(NSString *)password error:(NSError **)error;
+ (NSString *)stringFromData:(NSData *)data;

@end