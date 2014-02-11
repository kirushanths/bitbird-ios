//
//  GameOverScene.m
//  bitbird-ios
//
//  Created by Kirushanth on 2014-02-10.
//  Copyright (c) 2014 BitGames. All rights reserved.
//

#import "GameOverScene.h"
#import "GameScene.h"

@interface GameOverScene ()

@property (nonatomic, strong) UIView *adView;

@end

@implementation GameOverScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        // 1
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        // 2
        NSString * message;
        message = @"Game Over";
        // 3
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        label.text = message;
        label.fontSize = 40;
        label.fontColor = [SKColor blackColor];
        label.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:label];
        
        
        NSString * retrymessage;
        retrymessage = @"Replay Game";
        SKLabelNode *retryButton = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        retryButton.text = retrymessage;
        retryButton.fontColor = [SKColor blackColor];
        retryButton.position = CGPointMake(self.size.width/2, 50);
        retryButton.name = @"retry";
        [retryButton setScale:.5];
        
        [self addChild:retryButton];
		
        [self showAdvert];
    }
    return self;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"retry"]) {
		[self startOver];
    }
}

- (void)showAdvert
{
	if (self.adView) {
		[self.adView removeFromSuperview];
	}
	self.adView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
	self.adView.backgroundColor = [UIColor blackColor];
	
	ADBannerView *bannerAd = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
	bannerAd.delegate = self;
	[self.adView addSubview:bannerAd];
	
	[self.view addSubview:self.adView];
}

- (void)startOver
{
	SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionRight duration:0.5];
	GameScene * scene = [GameScene sceneWithSize:self.view.bounds.size];
	scene.scaleMode = SKSceneScaleModeAspectFill;
	[self.view presentScene:scene transition: reveal];
}

#pragma mark - Ad Delegate

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
	
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error;
{
	NSLog(@"Banner Error %@", [error localizedDescription]);
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
	
}

@end