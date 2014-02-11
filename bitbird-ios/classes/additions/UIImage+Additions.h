//
//  UIImage+Additions.h
//  thm-ios-iphone
//
//  Created by DontLoginHere on 2013-10-29.
//  Copyright (c) 2013 THM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Additions)

// http://ioscodesnippet.com/2011/10/02/force-decompressing-uiimage-in-background-to-achieve/
// So after an image has successfully loaded from the web or cached out,
// create an operation and decompress the image with  objective-c [UIImage decodedImageWithImage:anImage];

+ (UIImage *)decodedImageWithImage:(UIImage *)image;

// http://stackoverflow.com/questions/18323591/uiimageview-filter-image-into-solid-color
// This function create a Image Context and draw the image with mask
// then clip the context to mask
// then fill the color user choosed.
// that can create a image shape with specify color icon.

+ (UIImage *)generateMonoImage: (UIImage *)icon withColor:(UIColor *)color;

+ (UIImage *)emptyBGWithSize:(CGSize)size withWhiteColor:(UIColor *)whiteColor andGrayColor:(UIColor *)grayColor;

@end
