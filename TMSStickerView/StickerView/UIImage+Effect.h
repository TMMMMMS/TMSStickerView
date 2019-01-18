//
//  UIImage+Effect.h
//  TMSStickerView
//
//  Created by TMS on 2019/1/17.
//  Copyright © 2019年 TMS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Effect)
+ (UIImage *)imageWithSize:(CGSize)size scale:(CGFloat)scale color:(UIColor *)solidColor;
- (UIImage *)imageWithRoundedCornerRadius:(CGFloat)cornerRadius;
@end
