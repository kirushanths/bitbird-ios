//
//  BGAppDelegate.m
//  bitbird-ios
//
//  Created by Kirushanth on 2014-02-10.
//  Copyright (c) 2014 BitGames. All rights reserved.
//

#import "BGAppDelegate.h"

@implementation BGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
