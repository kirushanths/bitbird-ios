//
//  BGBird.m
//  bitbird-ios
//
//  Created by Kirushanth on 2014-02-13.
//  Copyright (c) 2014 BitGames. All rights reserved.
//

#import "BGBird.h"

static const int NUM_FRAMES = 12;
static const float FRAMES_SEC = 1.0f/(float) NUM_FRAMES;

@implementation BGBird

+ (instancetype)createBird
{
	return [[self class] spriteNodeWithImageNamed:@"bird1.png"];
}

+ (NSArray *)animationFrames
{
	SKTexture *frame1 = [SKTexture textureWithImageNamed:@"bird1.png"];
	SKTexture *frame2 = [SKTexture textureWithImageNamed:@"bird2.png"];
	NSArray *array = @[ frame1, frame2 ];
	return array;
}

- (void)startAnimation
{
	SKAction *anim = [SKAction animateWithTextures:[[self class] animationFrames] timePerFrame:FRAMES_SEC resize:YES restore:NO];
	[self runAction:[SKAction repeatActionForever:anim]];
}

- (void)stopAnimation
{
	[self removeAllActions];
}

@end
