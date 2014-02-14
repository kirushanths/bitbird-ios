//
//  BGGameViewController.m
//  bitbird-ios
//
//  Created by Kirushanth on 2014-02-10.
//  Copyright (c) 2014 BitGames. All rights reserved.
//

#import "BGGameViewController.h"
#import "GameScene.h"

@interface BGGameViewController ()

@property (nonatomic, assign) int score;
@property (nonatomic, assign) int attempts;

@end

@implementation BGGameViewController

- (void)loadView
{
	CGRect windowBounds = [[UIScreen mainScreen] bounds];
	
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown ) {}
	else {}
	
	self.view = [[SKView alloc] initWithFrame:windowBounds];
	self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if (SYSTEM_VERSION_MIN_SDK_6)
        [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    SKView * skView = (SKView *) self.view;
    
    if (!skView.scene) {
        // Create and configure the scene.
        GameScene* scene = [GameScene sceneWithSize:skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        // Present the scene.
        [skView presentScene:scene];
    }
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}


@end
