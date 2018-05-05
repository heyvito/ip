//
//  IPBaseAddress.h
//  ip
//
//  Created by Victor Gama on 05/05/2018.
//  Copyright © 2018 Victor Gama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BigInt.h"

@protocol IPBaseAddress <NSObject>


/**
 Determines whether the current address is valid
 */
@property (nonatomic, readonly) BOOL valid;


/**
 When not valid, contains the error found during parsing.
 When valid, returns nil.
 */
@property (nonatomic, readonly) NSString *error;


/**
 Determines whether the provided parsed address was given in
 the "correct" format, based on RFC 5952, Page 10:
 A Recommendation for IPv6 Text Representation
 
 https://tools.ietf.org/html/rfc5952#page-10
 */
@property (nonatomic, readonly) BOOL correct;


/**
 Returns the current address as an string
 */
@property (nonatomic, readonly) NSString *address;


/**
 Returns how many groups composes the current address
 */
@property (nonatomic, readonly) uint8_t groups;


/**
 Returns whether the address represents an IPv4 address
 */
@property (nonatomic, readonly) BOOL v4;


/**
 Returns the subnet in which the current address is contained
 within
 */
@property (nonatomic, readonly) NSString *subnet;


/**
 Returns the current address' subnet mask
 */
@property (nonatomic, readonly) uint8_t subnetMask;


/**
 Returns the parsed subnet
 */
@property (nonatomic, readonly) NSString *parsedSubnet;


/**
 Returns the parsed address components. For instance, for 127.0.0.1, returns
 @[@"127", @"0", @"0", @"1"]
 */
@property (nonatomic, readonly) NSArray<NSString *> *parsedAddress;


/**
 Returns the address' mask
 */
@property (nonatomic, readonly) NSString *mask;


/**
 Initializes a new instance with a given address

 @param anAddress The address to be parsed
 @return A new instance representing the parsed address
 */
- (instancetype)initWithAddress:(NSString *)anAddress;


/**
 Computes the correct form of an address

 @return Returns a String representation of the parsed address in the correct
 form, expanding any supressed groups
 */
- (nonnull NSString *)correctForm;


/**
 Computes the address as a BigInteger

 @return Returns a BigInteger representation of the current address
 */
- (nonnull BigInt *)bigInteger;


/**
 Computes the first address in the range given by the current address' subnet.
 This is also known as the Network Address.

 @return a IPBaseAddress representing the first address of the subnet.
 */
- (nonnull id<IPBaseAddress>)startAddress;


/**
 Computes the last address in the range given by the current address' subnet.
 This is also known as the Broadcast Address.
 
 @return a IPBaseAddress representing the last address of the subnet.
 */
- (nonnull id<IPBaseAddress>)endAddress;


/**
 Computes the first N bits of the address

 @param aMask Quantity of bits to take from the address
 @return A base-2 string representing the bits taken
 */
- (nonnull NSString *)maskWith:(uint8_t)aMask;


/**
 Returns the address' bits in the given range as a base-2 string

 @param aStart First index of the range to be extracted from the address
 @param anEnd Last, exclusive index of the range to be extracted from the
 address
 @return A string representing the extracted bits using base-2
 */
- (nonnull NSString *)bitsBase2WithStart:(int)aStart andEnd:(int)anEnd;


/**
 Determines whether a given address is in the subnet of the current address

 @param anAddress Address to compare
 @return Whether the given address is contained within the subnet of the current
 address
 */
- (BOOL)isInSubnet:(id<IPBaseAddress>)anAddress;

/**
 Computes a zero-padded, base-2 representation of the current address
 
 @return An string representing the current address as a zero-padded, base-2 bit
 list
 */
- (nonnull NSString *)binaryZeroPad;


/**
 Computes the reversed-form ARPA address representation

 @return A string representing the address in its reversed-form ARPA address
 */
- (nonnull NSString *)reversedForm;

@optional


/**
 Initialises a new instance based on a BigInteger value

 @param aBigInteger BigInteger to be used to initialise a new Address instance
 @return An Address instance
 */
+ (instancetype)fromBigInteger:(nonnull BigInt *)aBigInteger;
@end
