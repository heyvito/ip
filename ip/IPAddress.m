//
//  IPAddress.m
//  ip
//
//  Created by Victor Gama on 05/05/2018.
//  Copyright © 2018 Victor Gama. All rights reserved.
//

#import "IPAddress.h"
#import "IPv4.h"
#import "IPv6.h"

@implementation IPAddress {
    id<IPBaseAddress> addrs;
}

+ (instancetype)addressFromString:(NSString *)aString {
    return [[self alloc] initWithAddress:aString];
}

- (instancetype)initWithAddress:(NSString *)anAddress {
    if((self = [super init]) == nil) return self;
    
    addrs = [[IPv4 alloc] initWithAddress:anAddress];
    if(!addrs.valid) {
        addrs = [[IPv6 alloc] initWithAddress:anAddress];
    }
    
    return self;
}

- (BOOL)valid { return addrs.valid; }
- (BOOL)correct { return addrs.correct; }
- (NSString *)error { return addrs.error; }
- (NSString *)address { return addrs.address; }
- (uint8_t)groups { return addrs.groups; }
- (BOOL)v4 { return addrs.v4; }
- (NSString *)subnet { return addrs.subnet; }
- (uint8_t)subnetMask { return addrs.subnetMask; }
- (NSString *)parsedSubnet { return addrs.parsedSubnet; }
- (NSArray<NSString *> *)parsedAddress { return addrs.parsedAddress; }
- (NSString *)mask { return addrs.mask; }

- (NSString *)correctForm { return [addrs correctForm]; }
- (BigInt *)bigInteger { return [addrs bigInteger]; }
- (id<IPBaseAddress>)startAddress { return [addrs startAddress]; }
- (id<IPBaseAddress>)endAddress { return [addrs endAddress]; }
- (NSString *)maskWith:(uint8_t)aMask { return [addrs maskWith:aMask]; }
- (NSString *)bitsBase2WithStart:(int)aStart andEnd:(int)anEnd { return [addrs bitsBase2WithStart:aStart andEnd:anEnd]; }
- (BOOL)isInSubnet:(id<IPBaseAddress>)anAddress { return [addrs isInSubnet:anAddress]; }
- (nonnull NSString *)binaryZeroPad { return [addrs binaryZeroPad]; }
- (NSString *)reversedForm { return [addrs reversedForm]; }

@end
