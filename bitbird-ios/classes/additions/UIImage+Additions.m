//
//  UIImage+Additions.m
//  thm-ios-iphone
//
//  Created by DontLoginHere on 2013-10-29.
//  Copyright (c) 2013 THM. All rights reserved.
//

#import "UIImage+Additions.h"

@implementation UIImage (Additions)

+ (UIImage *)decodedImageWithImage:(UIImage *)image
{
	//redraw image using device context
	//force decompression
	UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
	[image drawAtPoint:CGPointZero];
	UIImage *decompressedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return decompressedImage;
}

+ (UIImage *) generateMonoImage: (UIImage *)icon withColor:(UIColor *)color
{
    UIImage *finishImage;
    CGImageRef alphaImage = CGImageRetain(icon.CGImage);
    CGColorRef colorref = CGColorRetain(color.CGColor);
    
    UIGraphicsBeginImageContextWithOptions(icon.size, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGRect imageArea = CGRectMake (0, 0,
                                   icon.size.width, icon.size.height);
    
    // Don't know why if I don't translate the CTM, the image will be a *bottom* up
    // aka, head on bottom shape, so I need use TranlateCTM and ScaleCTM to let
    // all y-axis to be rotated.
    CGFloat height = icon.size.height;
    CGContextTranslateCTM(ctx, 0.0, height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    CGContextClipToMask(ctx, imageArea , alphaImage);
    
    CGContextSetFillColorWithColor(ctx, colorref);
    CGContextFillRect(ctx, imageArea);
    CGImageRelease(alphaImage);
    CGColorRelease(colorref);
    
    finishImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return finishImage;
}

/* https://gist.github.com/sneakyness/5422797 */

+ (UIImage *)emptyBGWithSize:(CGSize)size withWhiteColor:(UIColor *)whiteColor andGrayColor:(UIColor *)grayColor
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    int side = 16;
    
    for (int i = 0; i < size.width; i += side) {
        for (int j = 0; j < size.height; j += side) {
            
            if ((i + j) % (side * 2) == 0)
                [whiteColor setFill];
            else
                [grayColor setFill];
            
            CGRect r = CGRectMake(i, j, side, side);
            UIRectFill(r);
        }
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
    
    
//    CGFloat side = 16;
//    CGSize size = CGSizeMake(side, side);
//    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
//    
//    [[UIColor whiteColor] setFill];
//    UIRectFill((CGRect){.size = size});
//    
//    CGRect r = CGRectMake(0, 0, side / 2, side / 2);
//    [[UIColor colorWithWhite:0.8f alpha:1] setFill];
//    UIRectFill(r);
//    r.origin = CGPointMake(side / 2, side / 2);
//    UIRectFill(r);
//    
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return image;
}

@end
