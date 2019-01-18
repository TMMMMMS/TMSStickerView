//
//  UIImage+Effect.m
//  TMSStickerView
//
//  Created by TMS on 2019/1/17.
//  Copyright © 2019年 TMS. All rights reserved.
//

#import "UIImage+Effect.h"

@implementation UIImage (Effect)

+ (UIImage *)imageWithSize:(CGSize)size scale:(CGFloat)scale color:(UIColor *)solidColor
{
    UIGraphicsBeginImageContextWithOptions(size, YES, scale);
    CGRect drawRect = CGRectMake(0, 0, size.width, size.height);
    [solidColor set];
    UIRectFill(drawRect);
    UIImage *drawnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return drawnImage;
}

- (UIImage *)imageWithRoundedCornerRadius:(CGFloat)cornerRadius
{
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, self.scale);
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius] addClip];
    [self drawInRect:rect];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}
@end
