//
//  UILabel+LatoFont.h
//  thm-ios-iphone
//
//  Created by Kirushanth on 2013-05-31.
//  Copyright (c) 2013 THM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (LatoFont)

-(void)setFontSize:(CGFloat)fontSize;
-(void)setFontRegularSize:(CGFloat)fontSize;

+(void)updateFontsinView:(UIView *)rootView;

@end
