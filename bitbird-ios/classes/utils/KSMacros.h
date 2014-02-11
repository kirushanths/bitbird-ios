//
//  Created by Kiru on 2013-09-19.
//  Copyright (c) 2013 THM. All rights reserved.
//

#ifndef AppMacros_h
#define AppMacros_h

#define ThrowError(e) @throw [NSException exceptionWithName:e reason:e userInfo:nil]
#define AbstractClassRequiresOverride ThrowError(@"You must override this")

/* LOGGING */

#ifdef APP_DEBUG
#define DLog(...) NSLog(@"%@ %@", @"", [NSString stringWithFormat:__VA_ARGS__])
#define ALog(...) [[NSAssertionHandler currentHandler] handleFailureInFunction:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding] file:[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding] lineNumber:__LINE__ description:__VA_ARGS__]
#else
#define DLog(...) do { } while (0)
#ifndef NS_BLOCK_ASSERTIONS
#define NS_BLOCK_ASSERTIONS
#endif
#define ALog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#endif

/* Debug Helpers */

/* print out the calling function of current scope */
/* NOTE: #include <execinfo.h> */

#define LOG_CALLER_FUNCTION \
	void *addr[2]; \
	int nframes = backtrace(addr, sizeof(addr)/sizeof(*addr)); \
	if (nframes > 1) { \
		char **syms = backtrace_symbols(addr, nframes); \
		NSLog(@"%s: caller: %s", __func__, syms[1]); \
		free(syms); \
	} else { \
		NSLog(@"%s: *** Failed to generate backtrace.", __func__); \
	}

/* Instance Creation */

#define __BLOCK __block

#define __BLOCK_SELF_DEFINE __BLOCK typeof(self) __blockself __unused = self;


#define RUN_ASYNC_NEW_THREAD(block) \
	__BLOCK_SELF_DEFINE \
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);


#define RUN_SYNC_ON_MAIN_THREAD(block) \
    if (self) { \
        __BLOCK_SELF_DEFINE \
        if (![NSThread isMainThread]) { \
            dispatch_sync(dispatch_get_main_queue(), ^{ \
                if (!__blockself) return; \
                block(); \
            }); \
        } else { \
            block(); \
        } \
    }


#define CREATE_THREAD_SAFE_INSTANCE_NO_RETURN(instance, block) \
    if (nil == instance) { \
        RUN_SYNC_ON_MAIN_THREAD(block) \
    }

#define CREATE_THREAD_SAFE_INSTANCE(instance, block) \
    CREATE_THREAD_SAFE_INSTANCE_NO_RETURN(instance, block) \
    return instance;

#define CREATE_THREAD_SAFE_SINGLETON(instance, block) \
    if (nil != instance) { \
        return instance; \
    } \
    static dispatch_once_t pred = 0; \
    dispatch_once(&pred, block); \
    return instance;

/* ENUM Magic */
/* Based on http://stackoverflow.com/a/202511 */

#pragma mark - Enum Factory Macros

// expansion macro for enum value definition
#define ENUM_VALUE(name,assign) name assign,

// expansion macro for enum to string conversion
#define ENUM_CASE(name,assign) case name: return @#name;

// expansion macro for string to enum conversion
#define ENUM_STRCMP(name,assign) if (![string isEqualToString:@#name]) return name;

/// declare the access function and define enum values
#define DECLARE_ENUM(EnumType, ENUM_DEF) \
	typedef enum EnumType { \
		ENUM_DEF(ENUM_VALUE) \
	} EnumType; \
	NSString *NSStringFrom##EnumType(EnumType value); \
	EnumType EnumType##FromNSString(NSString *string);

// Define Functions
#define DEFINE_ENUM(EnumType, ENUM_DEF) \
	NSString *NSStringFrom##EnumType(EnumType value) { \
		switch(value) { \
			ENUM_DEF(ENUM_CASE) \
			default: return @""; \
		} \
	} \
	EnumType EnumType##FromNSString(NSString *string) { \
		ENUM_DEF(ENUM_STRCMP) \
		return (EnumType)0; \
	}

/* IOS Versions */

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define SYSTEM_VERSION_MIN_SDK_7	SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")
#define SYSTEM_VERSION_MIN_SDK_6	SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")
#define SYSTEM_VERSION_MIN_SDK_5	SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")

/* http://forrst.com/posts/Useful_Objective_C_Preprocessor_Macros-m0z */

#define ApplicationDelegate                 ((MyAppDelegate *)[[UIApplication sharedApplication] delegate])
#define UserDefaults                        [NSUserDefaults standardUserDefaults]
#define SharedApplication                   [UIApplication sharedApplication]
#define Bundle                              [NSBundle mainBundle]
#define MainScreen                          [UIScreen mainScreen]
#define ShowNetworkActivityIndicator()      [UIApplication sharedApplication].networkActivityIndicatorVisible = YES
#define HideNetworkActivityIndicator()      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO
#define NetworkActivityIndicatorVisible(x)  [UIApplication sharedApplication].networkActivityIndicatorVisible = x
#define NavBar                              self.navigationController.navigationBar
#define TabBar                              self.tabBarController.tabBar
#define NavBarHeight                        self.navigationController.navigationBar.bounds.size.height
#define TabBarHeight                        self.tabBarController.tabBar.bounds.size.height
#define ScreenWidth                         [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight                        [[UIScreen mainScreen] bounds].size.height
#define TouchHeightDefault                  44
#define TouchHeightSmall                    32
#define ViewWidth(v)                        v.frame.size.width
#define ViewHeight(v)                       v.frame.size.height
#define ViewX(v)                            v.frame.origin.x
#define ViewY(v)                            v.frame.origin.y
#define SelfViewWidth                       self.view.bounds.size.width
#define SelfViewHeight                      self.view.bounds.size.height
#define RectX(f)                            f.origin.x
#define RectY(f)                            f.origin.y
#define RectWidth(f)                        f.size.width
#define RectHeight(f)                       f.size.height
#define RectSetWidth(f, w)                  CGRectMake(RectX(f), RectY(f), w, RectHeight(f))
#define RectSetHeight(f, h)                 CGRectMake(RectX(f), RectY(f), RectWidth(f), h)
#define RectSetX(f, x)                      CGRectMake(x, RectY(f), RectWidth(f), RectHeight(f))
#define RectSetY(f, y)                      CGRectMake(RectX(f), y, RectWidth(f), RectHeight(f))
#define RectSetSize(f, w, h)                CGRectMake(RectX(f), RectY(f), w, h)
#define RectSetOrigin(f, x, y)              CGRectMake(x, y, RectWidth(f), RectHeight(f))
#define DATE_COMPONENTS                     NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
#define TIME_COMPONENTS                     NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit
#define FlushPool(p)                        [p drain]; p = [[NSAutoreleasePool alloc] init]
#define RGB(r, g, b)                        [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define RGBA(r, g, b, a)                    [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]



#endif
