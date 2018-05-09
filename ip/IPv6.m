//
//  IPv6.m
//  ip
//
//  Created by Victor Gama on 05/05/2018.
//  Copyright © 2018 Victor Gama. All rights reserved.
//

#import "IPv6.h"
#import "IPv4.h"
#import "IPConstants.h"
#import "NSString+stringByPaddingLeftToLength.h"

const static uint8_t BITS = 128;
const static uint8_t GROUPS = 8;

@implementation IPv6 {
    NSString *_subnet;
    uint8_t _subnetMask;
    NSString *_zone;
    NSString *_address;
    NSString *_parsedSubnet;
    BOOL _valid;
    BOOL _v4;
    NSString *_error;
    NSString *_addressMinusSuffix;
    NSArray<NSString *> *_parsedAddress;
    uint8_t _groups;
    uint8_t _elidedGroups;
    uint8_t _elisionBegin;
    uint8_t _elisionEnd;
}

- (instancetype)initWithAddress:(NSString *)anAddress {
    return [self initWithAddress:anAddress andGroups:GROUPS];
}

- (instancetype)initWithAddress:(NSString *)anAddress andGroups:(uint8_t)groups {
    if((self = [super init]) == nil) return self;
    
    _groups = groups;
    _subnet = @"/128";
    _subnetMask = 128;
    _zone = @"";
    _address = anAddress;
    
    NSRegularExpression *subnetRegexp = [NSRegularExpression regularExpressionWithPattern:V6_RE_SUBNET_STRING options:0 error:nil];
    NSRegularExpression *forwardSlashRegexp = [NSRegularExpression regularExpressionWithPattern:@"/" options:0 error:nil];
    NSTextCheckingResult *result = [subnetRegexp firstMatchInString:anAddress options:0 range:NSMakeRange(0, anAddress.length)];
    NSTextCheckingResult *forwardSlashResult = [forwardSlashRegexp firstMatchInString:anAddress options:0 range:NSMakeRange(0, anAddress.length)];
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
    } else if(forwardSlashResult != nil) {
        _valid = NO;
        _error = @"Invalid subnet mask";
        return self;
    }
    
    NSRegularExpression *zoneRegexp = [NSRegularExpression regularExpressionWithPattern:V6_RE_ZONE_STRING options:0 error:nil];
    NSTextCheckingResult *zoneResult = [zoneRegexp firstMatchInString:anAddress options:0 range:NSMakeRange(0, anAddress.length)];
    if(zoneResult != nil) {
        _zone = [anAddress substringWithRange:[zoneResult rangeAtIndex:0]];
        anAddress = [anAddress substringWithRange:NSMakeRange(0, [zoneResult rangeAtIndex:0].location)];
    }
    
    _addressMinusSuffix = anAddress;
    _parsedAddress = [self parse:_addressMinusSuffix];
    return self;
}

- (NSString *)parsev4inv6:(NSString *)anAddress {
    
    NSString *addrs = [anAddress copy];
    NSMutableArray<NSString *> *groups = [NSMutableArray arrayWithArray:[addrs componentsSeparatedByString:@":"]];
    NSString *lastGroup = [groups lastObject];
    
    NSRegularExpression *addressRegexp = [NSRegularExpression regularExpressionWithPattern:V4_RE_ADDRESS_STRING options:0 error:nil];
    NSTextCheckingResult *addressResult = [addressRegexp firstMatchInString:lastGroup options:0 range:NSMakeRange(0, lastGroup.length)];
    if(addressResult != nil) {
        IPv4 *tmpv4 = [[IPv4 alloc] initWithAddress:[lastGroup substringWithRange:[addressResult rangeAtIndex:0]]];
        NSRegularExpression *prefixRegexp = [NSRegularExpression regularExpressionWithPattern:@"^0[0-9]+" options:0 error:nil];
        NSTextCheckingResult *prefixResult;
        for(int i = 0; i < tmpv4.groups; i++) {
            prefixResult = [prefixRegexp firstMatchInString:tmpv4.parsedAddress[i] options:0 range:NSMakeRange(0, tmpv4.parsedAddress[i].length)];
            if(prefixResult != nil) {
                _valid = NO;
                _error = @"IPv4 addresses cannot have leading zeroes";
                
                return addrs;
            }
        }
        _v4 = YES;
        groups[groups.count - 1] = [tmpv4 v6Group];
        
        addrs = [groups componentsJoinedByString:@":"];
    }
    
    return addrs;
}

- (NSArray<NSString *> *)parse:(NSString *)anAddress {
    anAddress = [self parsev4inv6:anAddress];
    if(_error != nil) return nil;
    
    NSRegularExpression *badCharsRegexp = [NSRegularExpression regularExpressionWithPattern:V6_RE_BAD_CHARACTERS_STRING options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray<NSTextCheckingResult *> *badCharsResult = [badCharsRegexp matchesInString:anAddress options:0 range:NSMakeRange(0, anAddress.length)];
    if(badCharsResult.count > 0) {
        _valid = NO;
        NSMutableArray<NSString *> *errors = [[NSMutableArray alloc] initWithCapacity:badCharsResult.count];
        for(int i = 0; i < badCharsResult.count; i++) {
            [errors addObject:[anAddress substringWithRange:[badCharsResult[i] rangeAtIndex:1]]];
        }
        _error = [NSString stringWithFormat:@"Bad character%@ detected in address: %@", badCharsResult.count > 1 ? @"s" : @"", [errors componentsJoinedByString:@""]];
        return nil;
    }
    
    NSRegularExpression *badAddressRegexp = [NSRegularExpression regularExpressionWithPattern:V6_RE_BAD_ADDRESS options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray<NSTextCheckingResult *> *badAddressResult = [badAddressRegexp matchesInString:anAddress options:0 range:NSMakeRange(0, anAddress.length)];
    if(badAddressResult.count > 0) {
        _valid = NO;
        NSMutableArray<NSString *> *errors = [[NSMutableArray alloc] initWithCapacity:badAddressResult.count];
        for(int i = 0; i < badAddressResult.count; i++) {
            [errors addObject:[anAddress substringWithRange:[badAddressResult[i] rangeAtIndex:1]]];
        }
        _error = [NSString stringWithFormat:@"Address failed regex: %@", [errors componentsJoinedByString:@" "]];
        return nil;
    }
    
    NSMutableArray<NSString *> *groups;
    NSArray<NSString *> *halves = [anAddress componentsSeparatedByString:@"::"];
    
    if(halves.count == 2) {
        NSArray<NSString *> *first = [halves[0] componentsSeparatedByString:@":"];
        NSArray<NSString *> *last = [halves[1] componentsSeparatedByString:@":"];
        
        if(first.count == 1 && first[0].length == 0) {
            first = @[];
        }
        
        if(last.count == 1 && last[0].length == 0) {
            last = @[];
        }
        
        int remaining = _groups - ((uint8_t)first.count + (uint8_t)last.count);
        
        if(remaining == 0) {
            _valid = false;
            _error = @"Error parsing groups";
            return nil;
        }
        
        _elidedGroups = remaining;
        _elisionBegin = (uint8_t)first.count;
        _elisionEnd = (uint8_t)first.count + _elidedGroups;
        
        groups = [[NSMutableArray alloc] initWithCapacity:_groups];
        [groups addObjectsFromArray:first];
        
        for(int i = 0; i < remaining; i++) {
            [groups addObject:@"0"];
        }
        
        [groups addObjectsFromArray:last];
    } else if(halves.count == 1) {
        groups = [NSMutableArray arrayWithArray:[anAddress componentsSeparatedByString:@":"]];
        _elidedGroups = 0;
    } else {
        _valid = NO;
        _error = @"Too many :: groups found";
        return nil;
    }
    
    NSString *tmpString;
    for(int i = 0; i < groups.count; i++) {
        tmpString = [NSString stringWithFormat:@"%x", (int)strtol([groups[i] UTF8String], nil, 16)];
        groups[i] = [tmpString copy];
    }
    
    if(groups.count != _groups) {
        _valid = NO;
        _error = @"Incorrect number of groups found";
        return nil;
    }
    
    _valid = YES;
    
    return groups;
}

- (NSString *)correctForm {
    if(_parsedAddress == nil) return nil;
    
    NSMutableArray<NSArray<NSNumber *> *> *zeroes = [[NSMutableArray alloc] init];
    int zeroCounter = 0;
    for(int i = 0; i < _parsedAddress.count; i++) {
        int value = (int)strtol([_parsedAddress[i] UTF8String], nil, 16);
        
        if(value == 0) {
            zeroCounter++;
        }
        
        if(value != 0 && zeroCounter > 0) {
            if(zeroCounter > 1) {
                [zeroes addObject:@[@(i - zeroCounter), @(i - 1)]];
            }
            
            zeroCounter = 0;
        }
    }
    
    if(zeroCounter > 1) {
        [zeroes addObject:@[@(_parsedAddress.count - zeroCounter), @(_parsedAddress.count - 1)]];
    }
    
    NSMutableArray<NSNumber *> *zeroLengths = [[NSMutableArray alloc] init];
    for(NSArray<NSNumber *> *zero in zeroes) {
        [zeroLengths addObject:@((zero[1].intValue - zero[0].intValue) + 1)];
    }
    
    NSMutableArray<NSString *> *groups;
    if(zeroes.count > 0) {
        int idx = 0;
        {
            float max = -MAXFLOAT;
            int _idx = 0;
            float x;
            for (NSNumber *num in zeroLengths) {
                x = num.floatValue;
                if (x > max) {
                    max = x;
                    idx = _idx;
                }
                _idx++;
            }
        }
        
        groups = [NSMutableArray arrayWithArray:[[self class] compact:_parsedAddress withSlice:zeroes[idx]]];
    } else {
        groups = [NSMutableArray arrayWithArray:_parsedAddress];
    }
    
    NSString *tmpString;
    for(int i = 0; i < groups.count; i++) {
        if(![groups[i] isEqualToString:@"compact"]) {
            tmpString = [groups[i] copy];
            groups[i] = [NSString stringWithFormat:@"%x", (int)strtol([tmpString UTF8String], nil, 16)];
        }
    }
    
    NSMutableString *correct = [[groups componentsJoinedByString:@":"] mutableCopy];
    {
        NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"^compact$" options:0 error:nil];
        [regexp replaceMatchesInString:correct options:0 range:NSMakeRange(0, correct.length) withTemplate:@"::"];
    }
    {
        NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"^compact|compact$" options:0 error:nil];
        [regexp replaceMatchesInString:correct options:0 range:NSMakeRange(0, correct.length) withTemplate:@":"];
    }
    {
        NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"compact" options:0 error:nil];
        [regexp replaceMatchesInString:correct options:0 range:NSMakeRange(0, correct.length) withTemplate:@""];
    }
    
    return correct;
}

+ (NSArray<NSString *> *)compact:(NSArray<NSString *> *)anAddressArray withSlice:(NSArray<NSNumber *> *)anSliceArray {
    NSMutableArray<NSString *> *s1 = [[NSMutableArray alloc] init];
    NSMutableArray<NSString *> *s2 = [[NSMutableArray alloc] init];

    for(int i = 0; i < anAddressArray.count; i++) {
        if(i < anSliceArray[0].intValue) {
            [s1 addObject:anAddressArray[i]];
        } else if(i > anSliceArray[1].intValue) {
            [s2 addObject:anAddressArray[i]];
        }
    }
    
    return [[s1 arrayByAddingObjectsFromArray:@[@"compact"]] arrayByAddingObjectsFromArray:s2];
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
        int component = (int)strtol([rawComponent UTF8String], nil, 16);
        [hexString appendString:[NSString stringWithFormat:@"%04x", component]];
    }
    
    return [[BigInt alloc] initWithString:hexString andRadix:16];
}

+ (instancetype)fromBigInteger:(nonnull BigInt *)aBigInteger {
    NSString *hex = [[[aBigInteger toStringWithRadix:16] stringByPaddingLeftToLength:32 withString:@"0"] lowercaseString];
    NSMutableArray<NSString *> *groups = [[NSMutableArray alloc] init];
    for(int i = 0; i < 8; i++) {
        [groups addObject:[hex substringWithRange:NSMakeRange(i * 4, 4)]];
    }
    
    return [[self alloc] initWithAddress:[groups componentsJoinedByString:@":"]];
}

- (nonnull id<IPBaseAddress>)startAddress {
    BigInt *startAddrs = [[BigInt alloc] initWithString:[self.mask stringByPaddingToLength:BITS - _subnetMask withString:@"0" startingAtIndex:self.mask.length] andRadix:2];
    return [[self class] fromBigInteger:startAddrs];
}

- (nonnull id<IPBaseAddress>)endAddress {
    BigInt *endAddrs = [[BigInt alloc] initWithString:[self.mask stringByPaddingToLength:BITS - _subnetMask withString:@"1" startingAtIndex:self.mask.length] andRadix:2];
    
    return [[self class] fromBigInteger:endAddrs];
}

- (NSString *)canonicalForm {
    NSMutableArray<NSString *> *arr = [[NSMutableArray alloc] initWithCapacity:_parsedAddress.count];
    for(NSString *n in _parsedAddress) {
        int val = (int)strtol([n UTF8String], nil, 16);
        [arr addObject:[NSString stringWithFormat:@"%04x", val]];
    }
    return [arr componentsJoinedByString:@":"];
}



- (BigInt *)bitsWithStart:(int)aStart andEnd:(int)anEnd {
    return [[BigInt alloc] initWithString:[self bitsBase2WithStart:aStart andEnd:anEnd] andRadix:2];
}

- (NSString *)bitsBase16WithStart:(int)aStart andEnd:(int)anEnd {
    int len = anEnd - aStart;
    if (len % 4 != 0) {
        return nil;
    }
    
    return [[[self bitsWithStart:aStart andEnd:anEnd] toStringWithRadix:16]  stringByPaddingLeftToLength:len / 4 withString:@"0"];
}

- (NSString *)v4inv6 {
    NSString *binary = [self binaryZeroPad];
    IPv4 *addressV4 = [IPv4 ipv4FromHex:[[[BigInt alloc] initWithString:[binary substringWithRange:NSMakeRange(96, 32)] andRadix:2] toStringWithRadix:16]];
    IPv6 *addressV6 = [[IPv6 alloc] initWithAddress:[[_parsedAddress subarrayWithRange:NSMakeRange(0, 6)] componentsJoinedByString:@":"] andGroups:6];
    NSString *correct = [addressV6 correctForm];
    NSString *infix = @"";
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@":$" options:0 error:nil];
    NSTextCheckingResult *result = [regexp firstMatchInString:correct options:0 range:NSMakeRange(0, correct.length)];
    if(result == nil) {
        infix = @":";
    }
    
    return [@[correct, infix, addressV4.address] componentsJoinedByString:@""];
}

- (NSString *)decimal {
    if(!_valid) return nil;
    NSMutableArray<NSString *> *parts = [[NSMutableArray alloc] initWithCapacity:_parsedAddress.count];
    for(NSString *n in _parsedAddress) {
        [parts addObject:[NSString stringWithFormat:@"%05d", (int)strtol([n UTF8String], nil, 16)]];
    }
    return [parts componentsJoinedByString:@":"];
}

- (NSString *)reversedForm {
    NSString *components = [[[self canonicalForm] stringByReplacingOccurrencesOfString:@":" withString:@""] substringWithRange:NSMakeRange(0, (int)floor(_subnetMask / 4))];
    NSMutableString *reversed = [[NSMutableString alloc] initWithCapacity:(components.length * 2) + 10];
    for(int i = (int)components.length - 1; i >= 0; i--) {
        [reversed appendFormat:@"%c.", [components characterAtIndex:i]];
    }
    if(![reversed hasSuffix:@"."]) {
        [reversed appendString:@"."];
    }
    [reversed appendFormat:@"ip6.arpa."];
    return reversed;
}

#pragma mark Properties

- (BOOL)valid { return _valid; }

- (BOOL)correct {
    return [_addressMinusSuffix isEqualToString:[self correctForm]] &&
        (_subnetMask == 128 || [_parsedSubnet isEqualToString:[_subnet stringByReplacingOccurrencesOfString:@"/" withString:@""]]);
}

- (NSString *)error { return _error; }
- (NSString *)address { return _address; }
- (uint8_t)groups { return _groups; }
- (BOOL)v4 { return _v4; }
- (NSString *)subnet { return _subnet; }
- (uint8_t)subnetMask { return _subnetMask; }
- (NSString *)parsedSubnet { return _parsedSubnet; }
- (NSArray<NSString *> *)parsedAddress { return _parsedAddress; }
- (NSString *)mask { return [self maskWith:self.subnetMask]; }
- (NSString *)zone { return _zone; }
- (BOOL)canonical {
    return [_addressMinusSuffix isEqualToString:[self canonicalForm]];
}

@end
