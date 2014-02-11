//
//  UILabel+LatoFont.m
//  thm-ios-iphone
//
//  Created by Kirushanth on 2013-05-31.
//  Copyright (c) 2013 THM. All rights reserved.
//

#import "UILabel+LatoFont.h"
#import "BGConstants.h"

@implementation UILabel (LatoFont)

-(void)setFontSize:(CGFloat)fontSize
{
	[self setFont:SE_FONT_LIGHT(fontSize)];
}

-(void)setFontRegularSize:(CGFloat)fontSize
{
	[self setFont:SE_FONT(fontSize)];
}

+(void)updateFontsinView:(UIView *)rootView
{
	for (UIView *view in rootView.subviews) {
		if ([view isMemberOfClass:[UIButton class]]) {
			UIButton *button = (UIButton *) view;
			[button.titleLabel setFontSize:button.titleLabel.font.pointSize];
			button.exclusiveTouch = YES;
		} else if ([view isMemberOfClass:[UILabel class]]) {
			UILabel *label = (UILabel *) view;
			[label setFontSize:label.font.pointSize];
		} else if ([view isMemberOfClass:[UITextField class]]) {
			UITextField *textField = (UITextField *) view;
			[textField setFont:SE_FONT_LIGHT(textField.font.pointSize)];
		} else if ([view isMemberOfClass:[UITextView class]]) {
			UITextView *textView = (UITextView *) view;
			[textView setFont:SE_FONT_LIGHT(textView.font.pointSize)];
		} else {
			[UILabel updateFontsinView:view];
		}
	}
}

@end
