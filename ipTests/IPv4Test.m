//
//  IPv4Test.m
//  ipTests
//
//  Created by Victor Gama on 05/05/2018.
//  Copyright © 2018 Victor Gama. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <ip/ip.h>

@interface IPv4Test : XCTestCase

@end

@implementation IPv4Test

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testValidAddress {
    IPv4 *v4 = [[IPv4 alloc] initWithAddress:@"127.0.0.1"];
    XCTAssert(v4.correct);
    XCTAssert([[v4 correctForm] isEqualToString:@"127.0.0.1"]);
}

- (void)testAddressWithSubnet {
    IPv4 *a = [[IPv4 alloc] initWithAddress:@"127.0.0.1/14"];
    IPv4 *b = [[IPv4 alloc] initWithAddress:@"127.0.0.1/14"];
    XCTAssert([a isInSubnet:b]);
}

- (void)testSmallSubnetContainedByLargerSubnets {
    IPv4 *address = [[IPv4 alloc] initWithAddress:@"127.0.0.1/16"];
    for(int i = 15; i > 0; i--) {
        IPv4 *larger = [[IPv4 alloc] initWithAddress:[NSString stringWithFormat:@"127.0.0.1/%d", i]];
        
        XCTAssert([address isInSubnet:larger]);
    }
}

- (void)testLargeSubnetNotContainedBySmallerSubnets {
    IPv4 *address = [[IPv4 alloc] initWithAddress:@"127.0.0.1/8"];
    
    for(int i = 9; i<= 32; i++) {
        IPv4 *smaller = [[IPv4 alloc] initWithAddress:[NSString stringWithFormat:@"127.0.0.1/%d", i]];
        XCTAssertFalse([address isInSubnet:smaller]);
    }
}

- (void)testIntegerParsing {
    IPv4 *address = [IPv4 ipv4FromInteger:432432423];
    
    XCTAssert(address.valid);
    XCTAssert([@"25.198.101.39" isEqualToString:address.address]);
    XCTAssert([@"/32" isEqualToString:address.subnet]);
    XCTAssert(address.subnetMask == 32);
}

- (void)testHexParsing {
    IPv4 *address = [IPv4 ipv4FromHex:@"19c66527"];
    
    XCTAssert(address.valid);
    XCTAssert([@"25.198.101.39" isEqualToString:address.address]);
    XCTAssert([@"/32" isEqualToString:address.subnet]);
    XCTAssert(address.subnetMask == 32);
}

- (void)testAddressWithSubnetExtra {
    IPv4 *address = [[IPv4 alloc] initWithAddress:@"127.0.0.1/16"];
    XCTAssert(address.valid);
    XCTAssert([address.subnet isEqualToString:@"/16"]);
    XCTAssert([address isInSubnet:[[IPv4 alloc] initWithAddress:@"127.0.0.1/16"]]);
    XCTAssertFalse([address isInSubnet:[[IPv4 alloc] initWithAddress:@"192.168.0.1/16"]]);
}

- (void)testInstantiateFromBigInteger {
    IPv4 *address = [IPv4 fromBigInteger:[[BigInt alloc] initWithInt:2130706433]];
    XCTAssert(address.valid);
    XCTAssert([address.address isEqualToString:@"127.0.0.1"]);
}

- (void)testConvertToBigInteger {
    IPv4 *address = [[IPv4 alloc] initWithAddress:@"127.0.0.1"];
    XCTAssertEqual(2130706433, [[address bigInteger] intValue]);
}

- (void)testInstantiateFromHex {
    IPv4 *address = [IPv4 ipv4FromHex:@"7f:00:00:01"];
    
    XCTAssert(address.valid);
    XCTAssert([@"127.0.0.1" isEqualToString:address.address]);
}

- (void)testConvertToHex {
    IPv4 *address = [[IPv4 alloc] initWithAddress:@"127.0.0.1"];
    
    XCTAssert([@"7f:00:00:01" isEqualToString:[address hex]]);
}

- (void)testNotationsForAddress {
    NSArray<NSString *> *addresses = @[
                                       @"127.0.0.1/32",
                                       @"127.0.0.1/032",
                                       @"127.000.000.001/032",
                                       @"127.000.000.001/32",
                                       @"127.0.0.1",
                                       @"127.000.000.001",
                                       @"127.000.0.1",
                                       ];
    for(NSString *addrs in addresses) {
        IPv4 *address = [[IPv4 alloc] initWithAddress:addrs];
        XCTAssert([[address correctForm] isEqualToString:@"127.0.0.1"]);
        XCTAssertEqual(32, address.subnetMask);
    }
}

- (void)testReversedForm {
    IPv4 *address = [[IPv4 alloc] initWithAddress:@"8.8.4.4"];
    XCTAssert([[address reversedForm] isEqualToString:@"4.4.8.8.in-addr.arpa."]);
}

- (void)testFromByteArray {
    uint8_t bytes[4] = {0x0a, 0x00, 0x01, 0x01};
    NSData *data = [NSData dataWithBytes:bytes length:4];
    IPAddress *addrs = [IPAddress addressWithData:data];
    XCTAssert([[addrs address] isEqualToString:@"10.0.1.1"]);
}

- (void)testData {
    uint8_t bytes[4] = {0x0a, 0x00, 0x01, 0x01};
    NSData *data = [NSData dataWithBytes:bytes length:4];
    IPv4 *address = [[IPv4 alloc] initWithAddress:@"10.0.1.1"];
    XCTAssert([address.data isEqualToData:data]);
}

@end
