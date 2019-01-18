//
//  TMSEmojiPreviewView.m
//  TMSStickerView
//
//  Created by TMS on 2019/1/15.
//  Copyright © 2019年 TMS. All rights reserved.
//

#import "TMSEmojiPreviewView.h"
#import <Masonry.h>

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)

@interface TMSEmojiPreviewView ()
@property (nonatomic, strong) UILabel *emojiLabel;
@end

@implementation TMSEmojiPreviewView

- (instancetype)init
{
    if (self = [super init]) {
        [self configViews];
    }
    return self;
}

- (void)setEmojiObj:(id)emojiObj {
    
    _emojiObj = emojiObj;
    
    if ([emojiObj isKindOfClass:[NSString class]]) {
        self.emojiLabel.text = emojiObj;
    }
    
}

- (void)configViews {
    
    UIImageView *bgImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"previewBg"]];
    [self addSubview:bgImg];
    [bgImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.bottom.equalTo(self);
        make.top.equalTo(self).offset(10);
        make.width.equalTo(@60);
    }];
    
    self.emojiLabel = [[UILabel alloc] init];
    self.emojiLabel.font = [UIFont systemFontOfSize:32];
    self.emojiLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.emojiLabel];
    [self.emojiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(SCREEN_WIDTH <= 320 ? @5 : @2);
        make.right.equalTo(self);
        make.top.equalTo(bgImg).offset(10);
    }];
}

@end

