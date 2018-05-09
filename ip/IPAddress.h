//
//  IPAddress.h
//  ip
//
//  Created by Victor Gama on 05/05/2018.
//  Copyright © 2018 Victor Gama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPBaseAddress.h"

@interface IPAddress : NSObject <IPBaseAddress>



/**
 Initialises a new IPAddress instance, by checking the provided data length and
 then initialising either a IPv4 or IPv6 instance.

 @param aData Data representing the address to be parsed
 @return A new instance of IPAddress retaining either a IPv4 or IPv6 address
 @throws A NSException representing an argument error when the provided data
 length does not correspond an IPv4 nor an IPv6 address
 */
+ (instancetype)addressWithData:(nonnull NSData *)aData;

/**
 Initialises a new IPAddress instance, by first attempting to parse the given
 address as an IPv4 address, and falling back to IPv6 in case it cannot be
 parsed. It is advisable to use the IPv4 and IPv6 classes in case the given
 address is known to be in the v4 or v6 format beforehand.

 @param aString A string representing an IP address
 @return A IPAddress instance backing the IPv4 or IPv6 address represented by
 the provided string
 */
+ (instancetype)addressFromString:(NSString *)aString;


/**
 The abstracted IP address backed by this generic instance. Returns either an
 IPv4 or IPv6 instance containing specific methods.
 */
@property (nonatomic, readonly) id<IPBaseAddress> underlyingAddress;

@end
