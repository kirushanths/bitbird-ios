//
//  BGAppDelegate.m
//  bitbird-ios
//
//  Created by Kirushanth on 2014-02-10.
//  Copyright (c) 2014 BitGames. All rights reserved.
//

#import "BGAppDelegate.h"
#import "BGGameViewController.h"
#import "iRate.h"

@implementation BGAppDelegate

+ (void)initialize
{
	[[iRate sharedInstance] setUsesUntilPrompt:5];
//	[[iRate sharedInstance] setPreviewMode:YES];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	BGGameViewController *gameVC = [[BGGameViewController alloc] init];
	
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
	self.window.rootViewController = gameVC;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
