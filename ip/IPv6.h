//
//  IPv6.h
//  ip
//
//  Created by Victor Gama on 05/05/2018.
//  Copyright © 2018 Victor Gama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPBaseAddress.h"

@class IPTeredoData;

@interface IPv6 : NSObject <IPBaseAddress>


/**
 Determines whether the current IPv6 is in its canonical form.
 */
@property (nonatomic, readonly) BOOL canonical;


/**
 Represents the current IPv6 zone
 */
@property (nonatomic, readonly) NSString *zone;


/**
 Initializes a new IPv6 instance with a provided address and group count

 @param anAddress An string representing the IPv6 address
 @param groups The number of groups that composes the address
 @return A new IPv6 instance with the provideed address and group count
 */
- (instancetype)initWithAddress:(nonnull NSString *)anAddress andGroups:(uint8_t)groups;


/**
 Computes the canonical form of the current IPv6

 @return A string representing the current IPv6 in its canonical form
 */
- (NSString *)canonicalForm;


/**
 Returns the IPv4-mapped IPv6 addresses form of the current address

 @return A string represneting the IPv4-mapped IPv6 addresses
 */
- (NSString *)v4inv6;


/**
 Computes the decimal form of the current address

 @return A string representing the current address in its decimal form
 */
- (NSString *)decimal;
@end
