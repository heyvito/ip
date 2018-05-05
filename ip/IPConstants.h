//
//  IPConstants.h
//  ip
//
//  Created by Victor Gama on 05/05/2018.
//  Copyright © 2018 Victor Gama. All rights reserved.
//

#ifndef IPConstants_h
#define IPConstants_h


static NSString *V4_RE_ADDRESS_STRING          = @"^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$";
static NSString *V4_RE_SUBNET_STRING           = @"/\\d{1,2}$";

static NSString *V6_RE_BAD_CHARACTERS_STRING   = @"([^0-9a-f:\\/%])";
static NSString *V6_RE_BAD_ADDRESS             = @"([0-9a-f]{5,}|:{3,}|[^:]:$|^:[^:]|\\/$)";
static NSString *V6_RE_SUBNET_STRING           = @"\\/\\d{1,3}(?=%|$)";
static NSString *V6_RE_ZONE_STRING             = @"%.*$";

#endif /* IPConstants_h */
