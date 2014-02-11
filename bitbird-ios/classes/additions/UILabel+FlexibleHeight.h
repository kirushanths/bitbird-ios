//
//  UILabel+FlexibleHeight.h
//  thm-ios-iphone
//
//  Created by DontLoginHere on 2013-10-17.
//  Copyright (c) 2013 THM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (FlexibleHeight)

-(float)resizeToFit;
-(float)expectedHeight;

+ (float)expectedHeightForText:(NSString *)text
                          font:(UIFont *)font
            constrainedToWidth:(float)width;

@end
