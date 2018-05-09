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

- (instancetype)initWithIP:(id<IPBaseAddress>)anAddress {
    if((self = [super init]) == nil) return self;
    addrs = anAddress;
    return self;
}

+ (instancetype)addressWithData:(NSData *)aData {
    if(aData.length == 4) { // IPv4
        uint8_t bytes[4];
        [aData getBytes:bytes length:4];
        int address = bytes[3];
        address |= bytes[2] << 8;
        address |= bytes[1] << 16;
        address |= bytes[0] << 24;
        address &= 0x0FFFFFFFF;
        return [[self alloc] initWithIP:[IPv4 ipv4FromInteger:address]];
    } else if(aData.length == 16) { //IPv6
        NSUInteger dataLength = aData.length;
        NSMutableString *string = [NSMutableString stringWithCapacity:dataLength*2];
        const unsigned char *dataBytes = [aData bytes];
        for (NSInteger idx = 0; idx < dataLength; ++idx) {
            [string appendFormat:@"%02x", dataBytes[idx]];
        }
        return [[self alloc] initWithIP:[IPv6 fromBigInteger:[[BigInt alloc] initWithString:string andRadix:16]]];
    } else {
        @throw [NSException exceptionWithName:@"ipInvalidLength"
                                       reason:@"The provided data length does not correspond to neighter a IPv4 nor a IPv6 address"
                                     userInfo:nil];
    }
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
