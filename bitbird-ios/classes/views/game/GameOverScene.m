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

@end

@implementation GameOverScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor blackColor];
    }
    return self;
}

- (void)didMoveToView:(SKView *)view
{
	[self startOver];
}

- (void)startOver
{
	SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionRight duration:0.5];
	GameScene * scene = [GameScene sceneWithSize:self.view.bounds.size];
	scene.scaleMode = SKSceneScaleModeAspectFill;
	[self.view presentScene:scene transition: reveal];
}


@end