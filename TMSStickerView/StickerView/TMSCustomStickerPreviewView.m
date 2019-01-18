//
//  TMSCustomStickerPreviewView.m
//  TMSStickerView
//
//  Created by TMS on 2019/1/15.
//  Copyright © 2019年 TMS. All rights reserved.
//

#import "TMSCustomStickerPreviewView.h"
#import "TMSEmojiViewConst.h"
#import "TMSEmoji.h"
#import <Masonry.h>

@interface TMSCustomStickerPreviewView ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, copy) NSString *currentStickerUrl;
@end

@implementation TMSCustomStickerPreviewView

- (instancetype)init {
    
    if (self == [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        self.imageView = [[UIImageView alloc] init];
        self.imageView.clipsToBounds = YES;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(10);
            make.centerX.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(80, 80));
            
        }];
    }
    return self;
}

- (void)setEmojiObj:(id)emojiObj {
    
    _emojiObj = emojiObj;
    
    if ([emojiObj isKindOfClass:[TMSCustomEmoji class]]) {
        TMSCustomEmoji *customEmoji = (TMSCustomEmoji *)emojiObj;
        if ([self.currentStickerUrl isEqualToString:customEmoji.pic]) {
            return;
        }
        self.currentStickerUrl = customEmoji.pic;
        self.imageView.image = nil;
        self.imageView.image = [UIImage imageNamed:self.currentStickerUrl];
    }
}

- (void)setPosition:(TMSCustomStickerPositionType)position {
    
    _position = position;
    
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:CGPointMake(10, lineH)];
    [path addLineToPoint:CGPointMake(rect.size.width-10, lineH)];
    
    [path addArcWithCenter:CGPointMake(rect.size.width-10-lineH, 10+lineH) radius:10 startAngle:3*M_PI/2 endAngle:M_PI*2 clockwise:YES];
    
    [path addLineToPoint:CGPointMake(rect.size.width-lineH, 10)];
    [path addLineToPoint:CGPointMake(rect.size.width-lineH, rect.size.height-arrowH*0.5-10)];
    
    [path addArcWithCenter:CGPointMake(rect.size.width-10-lineH, rect.size.height-arrowH*0.5-10-lineH) radius:10 startAngle:M_PI*2 endAngle:M_PI_2 clockwise:YES];
    
    [path addLineToPoint:CGPointMake(rect.size.width-10, rect.size.height-arrowH*0.5-lineH)];
    
    // 绘制箭头
    switch (self.position) {
        case TMSCustomStickerLocationTypeCenter:
        {
            [path addLineToPoint:CGPointMake((rect.size.width+arrowW)*0.5, rect.size.height-arrowH*0.5-lineH)];
            [path addLineToPoint:CGPointMake(rect.size.width*0.5, rect.size.height-lineH)];
            [path addLineToPoint:CGPointMake((rect.size.width-arrowW)*0.5, rect.size.height-arrowH*0.5-lineH)];
        }
            break;
        case TMSCustomStickerLocationTypeLeft:
        {
            [path addLineToPoint:CGPointMake(20+arrowW, rect.size.height-arrowH*0.5-lineH)];
            [path addLineToPoint:CGPointMake(20+arrowW*0.5, rect.size.height-lineH)];
            [path addLineToPoint:CGPointMake(20, rect.size.height-arrowH*0.5-lineH)];
        }
            break;
        case TMSCustomStickerLocationTypeRight:
        {
            [path addLineToPoint:CGPointMake(rect.size.width-20, rect.size.height-arrowH*0.5-lineH)];
            [path addLineToPoint:CGPointMake(rect.size.width-20-arrowW*0.5, rect.size.height-lineH)];
            [path addLineToPoint:CGPointMake(rect.size.width-20-arrowW, rect.size.height-arrowH*0.5-lineH)];
        }
            break;
            
        default:
            break;
    }
    
    [path addLineToPoint:CGPointMake(10, rect.size.height-arrowH*0.5-lineH)];
    
    [path addArcWithCenter:CGPointMake(10+lineH, rect.size.height-arrowH*0.5-10-lineH) radius:10 startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    
    [path addLineToPoint:CGPointMake(lineH, rect.size.height-arrowH*0.5-10)];
    
    [path addLineToPoint:CGPointMake(lineH, 10)];
    
    [path addArcWithCenter:CGPointMake(10+lineH, 10+lineH) radius:10 startAngle:M_PI endAngle:3*M_PI/2 clockwise:YES];
    
    [path closePath];
    
    path.lineWidth = lineH;
    
    [[UIColor whiteColor] set];
    [path fill];
    
    [[UIColor colorWithRed:208.0/255.0 green:208.0/255.0 blue:208.0/255.0 alpha:1] set];
    [path stroke];
    
}


@end

