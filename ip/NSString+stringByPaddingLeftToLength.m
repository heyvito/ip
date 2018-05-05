//
//  NSString+stringByPaddingLeftToLength.m
//  ip
//
//  Created by Victor Gama on 06/05/2018.
//  Copyright © 2018 Victor Gama. All rights reserved.
//

#import "NSString+stringByPaddingLeftToLength.h"

@implementation NSString (stringByPaddingLeftToLength)

- (NSString *)stringByPaddingLeftToLength:(NSUInteger)newLength withString:(NSString *)padString {
    if(self.length >= newLength) return self;
    return [NSString stringWithFormat:@"%@%@", [@"" stringByPaddingToLength:newLength - self.length withString:padString startingAtIndex:0], self];
}

@end
