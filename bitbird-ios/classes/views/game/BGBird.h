//
//  BGBird.h
//  bitbird-ios
//
//  Created by Kirushanth on 2014-02-13.
//  Copyright (c) 2014 BitGames. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface BGBird : SKSpriteNode

+ (instancetype)createBird;
- (void)startAnimation;
- (void)stopAnimation;

@end
