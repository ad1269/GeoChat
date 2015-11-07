//
//  ACEncryptor.m
//  NetworkTest
//
//  Created by AD Mohanraj on 6/22/15.
//  Copyright (c) 2015 AD. All rights reserved.
//

#import "ACEncryptor.h"

@implementation ACEncryptor

+ (NSData *)encryptData:(NSData *)data password:(NSString *)password error:(NSError **)error {
    
    return [self encryptData:data withSettings:kRNCryptorAES256Settings password:password error:error];
}

+ (NSString *)stringFromData:(NSData *)data {
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end