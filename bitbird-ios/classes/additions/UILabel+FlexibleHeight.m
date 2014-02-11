//
//  UILabel+FlexibleHeight.m
//  thm-ios-iphone
//
//  Created by DontLoginHere on 2013-10-17.
//  Copyright (c) 2013 THM. All rights reserved.
//

#import "UILabel+FlexibleHeight.h"

@implementation UILabel (FlexibleHeight)

- (float)resizeToFit
{
    float height = [self expectedHeight];
    CGRect newFrame = [self frame];
    newFrame.size.height = height;
    [self setFrame:newFrame];
    return newFrame.origin.y + newFrame.size.height;
}

- (float)expectedHeight
{
    [self setNumberOfLines:0];
    [self setLineBreakMode:NSLineBreakByWordWrapping];
    
    CGSize maximumLabelSize = CGSizeMake(self.frame.size.width, 9999);
    
    CGSize expectedLabelSize = [[self text] sizeWithFont:[self font]
                                       constrainedToSize:maximumLabelSize
                                           lineBreakMode:[self lineBreakMode]];
    return ceilf(expectedLabelSize.height);
}

+ (float)expectedHeightForText:(NSString *)text
                          font:(UIFont *)font
            constrainedToWidth:(float)width
{
    CGSize maximumLabelSize = CGSizeMake(width, 9999);
    CGSize expectedLabelSize = [text sizeWithFont:font
                                constrainedToSize:maximumLabelSize
                                    lineBreakMode:NSLineBreakByWordWrapping];
    return ceilf(expectedLabelSize.height);
}

@end
