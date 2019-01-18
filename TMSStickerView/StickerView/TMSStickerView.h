//
//  TMSStickerView.h
//  TMSStickerView
//
//  Created by TMS on 2019/1/15.
//  Copyright © 2019年 TMS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TMSCustomEmoji;

@protocol TMSEmojiViewDelegate<NSObject>

- (void)sendCustomEmojiItem:(TMSCustomEmoji *)emojiItem;

@end

@interface TMSStickerView : UIView

@property (nonatomic,copy) void(^sendActionBlock)(id emoji);
@property (strong, nonatomic) id<UITextInput> textView;
@property (weak, nonatomic) id<TMSEmojiViewDelegate> delegate;

/** 初始化表情控件(带自定义表情) */
+ (instancetype)showEmojiView;
/** 初始化表情控件(不带自定义表情) */
+ (instancetype)showEmojiViewWithoutCustomEmoji;

/** 设置控件为初始状态 */
- (void)initialState;
@end
