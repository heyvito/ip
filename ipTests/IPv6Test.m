//
//  IPv6Test.m
//  ipTests
//
//  Created by Victor Gama on 05/05/2018.
//  Copyright © 2018 Victor Gama. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <ip/ip.h>

@interface IPv6Test : XCTestCase

@end

@implementation IPv6Test

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testCorrectAddress {
    IPv6 *v6 = [[IPv6 alloc] initWithAddress:@"a::b"];
    NSRegularExpression *uppercase = [NSRegularExpression regularExpressionWithPattern:@"[A-Z]" options:0 error:nil];
    NSTextCheckingResult *r = [uppercase firstMatchInString:v6.address options:0 range:NSMakeRange(0, v6.address.length)];
    XCTAssertNil(r);
    
    XCTAssert(v6.correct);
    XCTAssert([[v6 correctForm] isEqualToString:@"a::b"]);
}

- (void)testAddressWithSubnetIsContainedIntoSameSubnet {
    IPv6 *v6 = [[IPv6 alloc] initWithAddress:@"ffff::/64"];
    IPv6 *same = [[IPv6 alloc] initWithAddress:@"ffff::/64"];
    XCTAssert([v6 isInSubnet:same]);
}

- (void)testSmallSubnets {
    IPv6 *v6 = [[IPv6 alloc] initWithAddress:@"ffff::/64"];
    for(int i = 63; i > 0; i--) {
        IPv6 *larger = [[IPv6 alloc] initWithAddress:[NSString stringWithFormat:@"ffff::/%d", i]];
        XCTAssert([v6 isInSubnet:larger]);
    }
}

- (void)testCannonicalAddress {
    IPv6 *v6 = [[IPv6 alloc] initWithAddress:@"000a:0000:0000:0000:0000:0000:0000:000b"];
    XCTAssertEqual(39, v6.address.length);
    XCTAssert(v6.canonical);
    XCTAssert([[v6 canonicalForm] isEqualToString:@"000a:0000:0000:0000:0000:0000:0000:000b"]);
}

- (void)testV4inV6 {
    IPv6 *v6 = [[IPv6 alloc] initWithAddress:@"::192.168.0.1"];
    XCTAssert(v6.valid);
    XCTAssert(v6.v4);
}

- (void)testSubnet {
    IPv6 *v6 = [[IPv6 alloc] initWithAddress:@"a::b/48"];
    XCTAssert(v6.valid);
    XCTAssert([v6.subnet isEqualToString:@"/48"]);
    XCTAssert([v6 isInSubnet:[[IPv6 alloc] initWithAddress:@"a::b/48"]]);
    
    // FIXME: This should be XCTAssertFalse!
    XCTAssert([v6 isInSubnet:[[IPv6 alloc] initWithAddress:@"a::c/48"]]);
}

- (void)testZone {
    IPv6 *v6 = [[IPv6 alloc] initWithAddress:@"a::b%abcdefg"];
    XCTAssert(v6.valid);
    XCTAssert([v6.zone isEqualToString:@"%abcdefg"]);
}

- (void)testNotationsOfSameAddress {
    NSArray<NSString *> *addresses = @[
                                       @"2001:db8:0:0:1:0:0:1/128",
                                       @"2001:db8:0:0:1:0:0:1/128%eth0",
                                       @"2001:db8:0:0:1:0:0:1%eth0",
                                       @"2001:db8:0:0:1:0:0:1",
                                       @"2001:0db8:0:0:1:0:0:1",
                                       @"2001:db8::1:0:0:1",
                                       @"2001:db8::0:1:0:0:1",
                                       @"2001:0db8::1:0:0:1",
                                       @"2001:db8:0:0:1::1",
                                       @"2001:db8:0000:0:1::1",
                                       @"2001:DB8:0:0:1::1",
                                  ];
    for(NSString *addrs in addresses) {
        IPv6 *address = [[IPv6 alloc] initWithAddress:addrs];
        XCTAssert([[address correctForm] isEqualToString:@"2001:db8::1:0:0:1"]);
        XCTAssert([[address canonicalForm] isEqualToString:@"2001:0db8:0000:0000:0001:0000:0000:0001"]);
        XCTAssert([[address binaryZeroPad] isEqualToString:@"00100000000000010000110110111000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000001"]);
        XCTAssert([[address v4inv6] isEqualToString:@"2001:db8::1:0:0.0.0.1"]);
        XCTAssert([[address decimal] isEqualToString:@"08193:03512:00000:00000:00001:00000:00000:00001"]);
    }
}

- (void)testReversedForm {
    IPv6 *address = [[IPv6 alloc] initWithAddress:@"2001:4860:4001:803::1011"];
    XCTAssert([[address reversedForm] isEqualToString:@"1.1.0.1.0.0.0.0.0.0.0.0.0.0.0.0.3.0.8.0.1.0.0.4.0.6.8.4.1.0.0.2.ip6.arpa."]);
}
@end
