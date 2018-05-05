//
//  NSString+stringByPaddingLeftToLength.h
//  ip
//
//  Created by Victor Gama on 06/05/2018.
//  Copyright © 2018 Victor Gama. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (stringByPaddingLeftToLength)
- (NSString *)stringByPaddingLeftToLength:(NSUInteger)newLength withString:(NSString *)padString;
@end
