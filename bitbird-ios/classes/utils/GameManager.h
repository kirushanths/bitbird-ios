//
//  GameManager.h
//  bitbird-ios
//
//  Created by Kirushanth on 2014-02-14.
//  Copyright (c) 2014 BitGames. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameManager : NSObject

+ (id)sharedInstance;

-(void)storeHighScore:(int)score;
-(int)retrieveHighScore;

-(void)resetKeyStore;


@end
