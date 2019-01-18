//
//  TMSCustomStickerPreviewView.h
//  TMSStickerView
//
//  Created by TMS on 2019/1/15.
//  Copyright © 2019年 TMS. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,TMSCustomStickerPositionType)
{
    
    TMSCustomStickerLocationTypeCenter,
    TMSCustomStickerLocationTypeLeft,
    TMSCustomStickerLocationTypeRight
    
};

@interface TMSCustomStickerPreviewView : UIView

@property (nonatomic, strong) id emojiObj;
// 控制箭头显示的方向
@property (nonatomic, assign) TMSCustomStickerPositionType position;

@end
