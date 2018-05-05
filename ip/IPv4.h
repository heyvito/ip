//
//  IPv4.h
//  ip
//
//  Created by Victor Gama on 05/05/2018.
//  Copyright © 2018 Victor Gama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPBaseAddress.h"

@interface IPv4 : NSObject <IPBaseAddress>


/**
 Converts the current IPv4 instance to a hex representation

 @return A string representing the current address in hexadecimal notation
 */
- (nonnull NSString *)hex;


/**
 Converts the current IPv4 instance to an IPv6 address group

 @return A string representing the current IPv4 in an IPv6 address group
 */
- (nonnull NSString *)v6Group;


/**
 Initialises a new IPv4 instance from a hexadecimal string

 @param anHex Hexadecimal string representing an IPv4 address
 @return Returns a new IPv4 instance with the provided hexadecimal address
 */
+ (nonnull instancetype)ipv4FromHex:(NSString *)anHex;


/**
 Initialises a new IPv4 instance from a integer
 
 @param anInteger Integer representing an IPv4 address
 @return Returns a new IPv4 instance with the provided integer
 */
+ (nonnull instancetype)ipv4FromInteger:(unsigned int)anInteger;

@end
