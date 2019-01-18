//
//  TMSStickerCollectionViewCell.h
//  TMSStickerView
//
//  Created by TMS on 2019/1/15.
//  Copyright © 2019年 TMS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TMSEmoji;
@class TMSStickerCollectionViewCell;

typedef void(^CellSendActionBlock)(id emoji);

@protocol TMSStickerCollectionViewCellDelegate <NSObject>

@optional
- (void)emojiCollectionViewCell:(TMSStickerCollectionViewCell *)emojiCollectionViewCell showEmojiPreviewViewWithEmoji:(id)emoji itemFrame:(CGRect)itemFrame;
- (void)emojiCollectionViewCellHideEmojiPreviewView:(TMSStickerCollectionViewCell *)emojiCollectionViewCell;

@end

@interface TMSStickerCollectionViewCell : UICollectionViewCell
@property (nonatomic, weak) id<TMSStickerCollectionViewCellDelegate> delegate;
@property (nonatomic,copy) CellSendActionBlock sendActionBlock;
@property (nonatomic, strong) TMSEmoji *systemEmoji;
@end

@interface TMSCustomStickerCollectionViewCell : TMSStickerCollectionViewCell

- (void)configEmojiWithEmoji:(TMSEmoji *)customEmoji showSlider:(BOOL)showSlider;

@end
