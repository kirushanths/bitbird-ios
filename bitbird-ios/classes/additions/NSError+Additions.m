//
//  NSError+Additions.m
//  thm-ios-iphone
//
//  Created by Kirushanth on 2013-12-16.
//  Copyright (c) 2013 THM. All rights reserved.
//

#import "NSError+Additions.h"

@implementation NSError (Additions)

- (BOOL)isConnectionUnstable
{
	switch (self.code) {
		case NSURLErrorTimedOut:
		case NSURLErrorCannotFindHost:
		case NSURLErrorCannotConnectToHost:
		case NSURLErrorNetworkConnectionLost:
		case NSURLErrorDNSLookupFailed:
		case NSURLErrorResourceUnavailable:
		case NSURLErrorNotConnectedToInternet:
		case NSURLErrorCannotLoadFromNetwork:
			return YES;
		default:
			return NO;
	}
}

@end
