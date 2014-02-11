//
//  NSString+Additions.m
//  thm-ios-iphone
//
//  Created by DontLoginHere on 2013-10-29.
//  Copyright (c) 2013 THM. All rights reserved.
//

#import "NSString+Additions.h"

@implementation NSString (Additions)

+ (NSString *)uniqueIdentifier
{
    CFUUIDRef theUniqueString = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUniqueString);
    CFRelease(theUniqueString);
    return (__bridge NSString *) string;
}

@end
