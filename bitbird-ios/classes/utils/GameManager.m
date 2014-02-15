//
//  GameManager.m
//  bitbird-ios
//
//  Created by Kirushanth on 2014-02-14.
//  Copyright (c) 2014 BitGames. All rights reserved.
//

#import "GameManager.h"
#import "KeychainItemWrapper.h"
#import "KSMacros.h"

#define kKeyChainStoreIdentifier @"BitBirdKeyStore"

@implementation GameManager

-(void)storeHighScore:(int)score
{
	//Store successful login creds
	KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:kKeyChainStoreIdentifier accessGroup:nil];
	[keychainItem resetKeychainItem];
	[keychainItem setObject:kKeyChainStoreIdentifier forKey:(__bridge id)kSecAttrService];
	[keychainItem setObject:kKeyChainStoreIdentifier forKey:(__bridge id)kSecAttrAccount];
	[keychainItem setObject:[NSString stringWithFormat:@"%d", score] forKey:(__bridge id)kSecValueData];
}

-(int)retrieveHighScore
{
	KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:kKeyChainStoreIdentifier accessGroup:nil];
	NSString *highScore = [keychainItem objectForKey:(__bridge id)kSecValueData];
	return highScore ? highScore.intValue : 0;
}

-(void)resetKeyStore
{
	KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:kKeyChainStoreIdentifier accessGroup:nil];
	[keychainItem resetKeychainItem];
}

#pragma mark SharedInstance - Singleton

static GameManager *_sharedInstance;

+ (instancetype)sharedInstance {
    CREATE_THREAD_SAFE_SINGLETON(_sharedInstance, ^{
		_sharedInstance = [[GameManager alloc] init];
	})
}

@end
