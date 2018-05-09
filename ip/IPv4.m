//
//  IPv4.m
//  ip
//
//  Created by Victor Gama on 05/05/2018.
//  Copyright © 2018 Victor Gama. All rights reserved.
//

#import "IPv4.h"
#import "IPConstants.h"
#import "NSString+stringByPaddingLeftToLength.h"

static const uint8_t BITS = 32;

@implementation IPv4 {
    BOOL _valid;
    NSString *_address;
    NSString *_subnet;
    uint8_t _subnetMask;
    NSString *_parsedSubnet;
    NSString *_error;
    NSString *_addressMinusSufix;
    NSArray<NSString *> *_parsedAddress;
}

- (instancetype)initWithAddress:(NSString *)anAddress {
    if((self = [super init]) == nil) return self;
    _valid = false;
    _address = anAddress;
    _subnet = @"/32";
    _subnetMask = 32;
    NSRegularExpression *subnetRegexp = [NSRegularExpression regularExpressionWithPattern:V4_RE_SUBNET_STRING options:0 error:nil];
    NSTextCheckingResult *result = [subnetRegexp firstMatchInString:anAddress options:0 range:NSMakeRange(0, anAddress.length)];
    if(result != nil) {
        _parsedSubnet = [[anAddress substringWithRange:[result rangeAtIndex:0]] stringByReplacingOccurrencesOfString:@"/" withString:@""];
        _subnetMask = (uint8_t)atoi([_parsedSubnet UTF8String]);
        _subnet = [NSString stringWithFormat:@"/%d", _subnetMask];
        
        if(_subnetMask < 0 || _subnetMask > BITS) {
            _valid = NO;
            _error = @"Invalid subnet mask";
            return self;
        }
        
        anAddress = [anAddress substringWithRange:NSMakeRange(0, [result rangeAtIndex:0].location)];
    }
    
    _addressMinusSufix = anAddress;
    _parsedAddress = [self parse:anAddress];
    
    return self;
}

- (NSArray<NSString *> *)parse:(NSString *)anAddress {
    NSArray<NSString *> *groups = [anAddress componentsSeparatedByString:@"."];
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:V4_RE_ADDRESS_STRING options:0 error:nil];
    NSTextCheckingResult *result = [re firstMatchInString:anAddress options:0 range:NSMakeRange(0, anAddress.length)];
    if(result == nil) {
        _valid = NO;
        _error = @"Invalid IPv4 Address";
    } else {
        _valid = YES;
    }
    
    return groups;
}

- (NSString *)correctForm {
    NSMutableArray<NSNumber *> *items = [[NSMutableArray alloc] init];
    for(NSString *g in _parsedAddress) {
        [items addObject:[NSNumber numberWithInt:atoi([g UTF8String])]];
    }
    return [items componentsJoinedByString:@"."];
}

- (BOOL)isInSubnet:(id<IPBaseAddress>)anAddress {
    if(self.subnetMask < anAddress.subnetMask) return false;
    if([[self maskWith:anAddress.subnetMask] isEqualToString:anAddress.mask]) return true;
    return false;
}

- (NSString *)maskWith:(uint8_t)aMask {
    return [self bitsBase2WithStart:0 andEnd:aMask];
}

- (NSString *)bitsBase2WithStart:(int)aStart andEnd:(int)anEnd {
    return [[self binaryZeroPad] substringWithRange:NSMakeRange(aStart, anEnd - aStart)];
}

- (NSString *)binaryZeroPad {
    return [[[self bigInteger] toStringWithRadix:2] stringByPaddingLeftToLength:BITS withString:@"0"];
}

- (BigInt *)bigInteger {
    if(!_valid) {
        return [[BigInt alloc] initWithInt:0];
    }
    NSMutableString *hexString = [[NSMutableString alloc] init];
    for(NSString *rawComponent in _parsedAddress) {
        int component = atoi([rawComponent UTF8String]);
        [hexString appendString:[NSString stringWithFormat:@"%02x", component]];
    }
    
    return [[BigInt alloc] initWithString:hexString andRadix:16];
}

+ (instancetype)ipv4FromInteger:(unsigned int)anInteger {
    return [self ipv4FromHex:[NSString stringWithFormat:@"%02x", anInteger]];
}

+ (instancetype)ipv4FromHex:(NSString *)anHex {
    NSString *padded = [[anHex stringByReplacingOccurrencesOfString:@":" withString:@""] stringByPaddingLeftToLength:8 withString:@"0"];
    NSMutableArray<NSNumber *> *groups = [[NSMutableArray alloc] init];
    for(int i = 0; i < 8; i += 2) {
        NSString *slice = [padded substringWithRange:NSMakeRange(i, 2)];
        [groups addObject:[NSNumber numberWithLong:strtol([slice UTF8String], nil, 16)]];
    }
    return [[self alloc] initWithAddress:[groups componentsJoinedByString:@"."]];
}

+ (instancetype)fromBigInteger:(BigInt *)aBigInteger {
    return [self ipv4FromInteger:[aBigInteger intValue]];
}

- (id<IPBaseAddress>)startAddress {
    
    BigInt *startAddrs = [[BigInt alloc] initWithString:[self.mask stringByPaddingToLength:BITS - _subnetMask withString:@"0" startingAtIndex:self.mask.length] andRadix:2];
    return [[self class] fromBigInteger:startAddrs];
}

- (id<IPBaseAddress>)endAddress {
    BigInt *startAddrs = [[BigInt alloc] initWithString:[self.mask stringByPaddingToLength:BITS - _subnetMask withString:@"1" startingAtIndex:self.mask.length] andRadix:2];
    return [[self class] fromBigInteger:startAddrs];
}


- (NSString *)hex {
    NSMutableArray<NSString *> *hexCommponents = [[NSMutableArray alloc] init];
    for(NSString *rawComponent in _parsedAddress) {
        int component = atoi([rawComponent UTF8String]);
        [hexCommponents addObject:[NSString stringWithFormat:@"%02x", component]];
    }
    return [hexCommponents componentsJoinedByString:@":"];
}

- (NSString *)v6Group {
    NSMutableArray<NSString *> *arr = [[NSMutableArray alloc] init];
    for(int i = 0; i < self.groups; i+= 2) {
        NSString *hex = [NSString stringWithFormat:@"%02x%02x", atoi([_parsedAddress[i] UTF8String]), atoi([_parsedAddress[i] UTF8String])];
        [arr addObject:[NSString stringWithFormat:@"%x", (uint8_t)strtol([hex UTF8String], nil, 16)]];
    }
    return [arr componentsJoinedByString:@":"];
}

- (NSString *)reversedForm {
    return [NSString stringWithFormat:@"%@.in-addr.arpa.", [[[_parsedAddress reverseObjectEnumerator] allObjects] componentsJoinedByString:@"."]];
}

- (NSData *)data {
    uint8_t bytes[4] = {
        (uint8_t)atoi([_parsedAddress[0] UTF8String]),
        (uint8_t)atoi([_parsedAddress[1] UTF8String]),
        (uint8_t)atoi([_parsedAddress[2] UTF8String]),
        (uint8_t)atoi([_parsedAddress[3] UTF8String]),
    };
    return [NSData dataWithBytes:&bytes length:4];
}

#pragma mark Properties

- (uint8_t)groups { return 4; }

- (BOOL)valid { return _valid; }

- (NSString *)address { return _address; }

- (BOOL)v4 { return true; }

- (NSString *)subnet { return _subnet; }

- (uint8_t)subnetMask { return _subnetMask; }

- (NSString *)parsedSubnet { return _parsedSubnet; }

- (NSArray<NSString *> *)parsedAddress { return _parsedAddress; }

- (BOOL)correct {
    return [_addressMinusSufix isEqualToString:[self correctForm]] && (_subnetMask == 32 || [_parsedSubnet isEqualToString:[_subnet stringByReplacingOccurrencesOfString:@"/" withString:@""]]);
}

- (NSString *)mask {
    return [self maskWith:self.subnetMask];
}

- (NSString *)error { return _error; }

@end
