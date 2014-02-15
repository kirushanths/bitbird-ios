//
//  BGGameViewController.m
//  bitbird-ios
//
//  Created by Kirushanth on 2014-02-10.
//  Copyright (c) 2014 BitGames. All rights reserved.
//

#import "BGGameViewController.h"
#import "GameScene.h"

@interface BGGameViewController () <ADBannerViewDelegate>

@property (nonatomic, strong) ADBannerView *bannerView;

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

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.canDisplayBannerAds = YES;
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
	
	SKView * skView = (SKView *) self.originalContentView;
    
    if (!skView.scene) {
        // Create and configure the scene.
        GameScene* scene = [GameScene sceneWithSize:skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        // Present the scene.
        [skView presentScene:scene];
    }
	
	[self showAdvert];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)showAdvert
{
	if (!self.bannerView) {
		self.bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
		self.bannerView.delegate = self;
		[self.view addSubview:self.bannerView];
	}
	
	self.bannerView.frame = CGRectMake(0, self.view.bounds.size.height - 50, 320, 50);
}

- (void)hideAdvert
{
	[self.bannerView removeFromSuperview];
	self.bannerView.delegate = nil;
	self.bannerView = nil;
}

#pragma mark - Ad Delegate

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
	NSLog(@"Banner did Load");
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error;
{
	NSLog(@"Banner Error %@", [error localizedDescription]);
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
	NSLog(@"Banner did Finish");
}

@end
