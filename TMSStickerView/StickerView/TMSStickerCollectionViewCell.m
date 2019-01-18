//
//  TMSStickerCollectionViewCell.m
//  TMSStickerView
//
//  Created by TMS on 2019/1/15.
//  Copyright © 2019年 TMS. All rights reserved.
//

#import "TMSStickerCollectionViewCell.h"
#import <Masonry.h>
#import "TMSEmoji.h"
#import "TMSEmojiViewConst.h"

#define WS(object)  __weak __typeof(object) weakSelf = object;
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define emojiRowCount ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 8 : ((SCREEN_WIDTH <= 320) ? 6 : 8))
#define customStickerRowCount ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 8 : 4)

@interface TMSEmojiItem : UIView
@property (nonatomic, strong) UILabel *emojiLabel;
@property (nonatomic, strong) UIButton *emojiBtn;
@property (nonatomic, strong) UIImageView *customImg;
@property (nonatomic, assign) TMSEmojiType emojiType;
@property (nonatomic, strong) id emojiObj;
@property (nonatomic,copy) void(^sendActionBlock)(id emoji);
@property (nonatomic, strong) UIView *highlightedView; // 长按高亮图
@end

@implementation TMSEmojiItem

- (instancetype)initWithSTEmojiType:(TMSEmojiType)emojiType {
    
    if (self == [super init]) {
        _emojiType = emojiType;
        [self configViews];
    }
    return self;
}

- (void)configViews {
    
    if (_emojiType == TMSEmojiTypeCustom) {
        
        self.highlightedView = [[UIView alloc] init];
        self.highlightedView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        self.highlightedView.alpha = 0;
        self.highlightedView.layer.cornerRadius = 5;
        self.highlightedView.layer.masksToBounds = YES;
        [self addSubview:self.highlightedView];
        [self.highlightedView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(4, 10, -8, 10));
        }];
        
        UIImageView *customImg = [[UIImageView alloc] init];
        customImg.contentMode = UIViewContentModeScaleAspectFit;
        customImg.userInteractionEnabled = YES;
        [customImg addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)]];
        [self addSubview:customImg];
        self.customImg = customImg;
        [customImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(@10);
            make.size.mas_equalTo(CGSizeMake(52, 52));
        }];
        
    } else {
        
        UILabel *emojiLabel = [[UILabel alloc] init];
        emojiLabel.font = [UIFont systemFontOfSize:24];
        emojiLabel.textAlignment = NSTextAlignmentCenter;
        emojiLabel.userInteractionEnabled = YES;
        [emojiLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapGesture:)]];
        [self addSubview:emojiLabel];
        self.emojiLabel = emojiLabel;
        [emojiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
}

- (void)labelTapGesture:(UITapGestureRecognizer *)gesture {
    
    self.sendActionBlock(self.emojiLabel.text);
}

- (void)tapGesture:(UITapGestureRecognizer *)gesture {
    
    if ([self.emojiObj isKindOfClass:[TMSCustomEmoji class]]) {
        TMSCustomEmoji *customEmoji = (TMSCustomEmoji *)self.emojiObj;
        if ([customEmoji.pic isEqualToString:@"local"]) {
            NSLog(@"添加表情");
        } else {
            self.sendActionBlock(self.emojiObj);
        }
    }
}

- (void)highlightedViewVisiable:(BOOL)isVisiable {
    
    if (isVisiable) {
        if (self.highlightedView.alpha == 1) {
            return;
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            self.highlightedView.alpha = 1;
        }];
        
    } else {
        if (self.highlightedView.alpha == 0) {
            return;
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            self.highlightedView.alpha = 0;
        }];
    }
}

- (void)setupContentViewWithEmoji:(id)obj showSlider:(BOOL)showSlider {
    
    self.emojiObj = obj;
    self.emojiLabel.text = nil;
    
    if ([obj isKindOfClass:[TMSCustomEmoji class]]) {

        TMSCustomEmoji *customEmoji = (TMSCustomEmoji *)obj;

        CGFloat itemW = showSlider ? 52 : 60;
        [self.customImg mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(itemW, itemW));
        }];

        if ([customEmoji.pic isEqualToString:@"local"]) {
            self.customImg.image = [UIImage imageNamed:@"icon_out_addEmoji"];
        } else {
            self.customImg.image = [UIImage imageNamed:customEmoji.pic];
        }
    } else {
        self.emojiLabel.text = obj;
    }
}

@end

@interface TMSStickerCollectionViewCell ()
@property (nonatomic, strong) UIView *emojiContainer;
@property (nonatomic, strong) NSArray<TMSEmojiItem *> *emojiItems;
@end

@implementation TMSStickerCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self == [super initWithFrame:frame]) {
        
        UIView *emojiContainer = [[UIView alloc] init];
        [self.contentView addSubview:emojiContainer];
        self.emojiContainer = emojiContainer;
        [emojiContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, cellPadding, 0, cellPadding));
        }];
        
        WS(self)
        CGFloat itemW = (SCREEN_WIDTH - 2*cellPadding) / emojiRowCount;
        NSMutableArray *itemArray = [NSMutableArray array];
        TMSEmojiItem *lastView = nil;
        for (NSInteger i = 0; i < emojiRow * emojiRowCount; i++) {
            
            TMSEmojiItem *item = [[TMSEmojiItem alloc] initWithSTEmojiType:TMSEmojiTypePeople];
            UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressEmoji:)];
            longPressRecognizer.minimumPressDuration = 0.2;
            [item addGestureRecognizer:longPressRecognizer];
            item.sendActionBlock = ^(id emoji) {
                weakSelf.sendActionBlock(emoji);
            };
            [emojiContainer addSubview:item];
            if (lastView) {
                if (i % emojiRowCount == 0) {
                    [item mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.equalTo(emojiContainer);
                        make.top.equalTo(lastView.mas_bottom);
                        make.size.mas_equalTo(CGSizeMake(itemW, itemH));
                    }];
                } else {
                    [item mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.equalTo(lastView.mas_right);
                        make.top.equalTo(lastView);
                        make.size.mas_equalTo(CGSizeMake(itemW, itemH));
                    }];
                }
            } else {
                [item mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.top.equalTo(emojiContainer);
                    make.size.mas_equalTo(CGSizeMake(itemW, itemH));
                }];
            }
            lastView = item;
            [itemArray addObject:item];
        }
        self.emojiItems = itemArray.copy;
    }
    return self;
}

- (void)setSystemEmoji:(TMSEmoji *)systemEmoji {
    
    _systemEmoji = systemEmoji;
    
    [self.emojiContainer.subviews enumerateObjectsUsingBlock:^(__kindof TMSEmojiItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx < systemEmoji.emojis.count) {
            [obj setupContentViewWithEmoji:systemEmoji.emojis[idx] showSlider:NO];
        } else {
            [obj setupContentViewWithEmoji:nil showSlider:NO];
        }
    }];
}

- (void)didLongPressEmoji:(UILongPressGestureRecognizer *)recognizer
{
    if (!self.emojiItems || !self.emojiItems.count) {
        return;
    }
    
    TMSEmojiItem *item = nil;
    CGPoint point = [recognizer locationInView:self];
    for (NSUInteger i = 0, max = self.emojiItems.count; i < max; i++) {
        if (CGRectContainsPoint(self.emojiItems[i].frame, point)) {
            if (i < self.emojiItems.count) {
                item = self.emojiItems[i];
            }
            break;
        }
    }
    
    NSString *emoji = item.emojiObj;
    if (emoji.length == 0) {
        [self hidePreviewViewWithItem:nil sendEmoji:NO];
        return;
    }
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            [self showPreviewViewWithItem:item];
            break;
        case UIGestureRecognizerStateChanged:
            [self showPreviewViewWithItem:item];
            break;
        case UIGestureRecognizerStateEnded:
            [self hidePreviewViewWithItem:item sendEmoji:YES];
            break;
        default:
            [self hidePreviewViewWithItem:item sendEmoji:NO];
            break;
    }
}

- (void)showPreviewViewWithItem:(TMSEmojiItem *)item
{
    if (!item) {
        [self hidePreviewViewWithItem:nil sendEmoji:NO];
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(emojiCollectionViewCell:showEmojiPreviewViewWithEmoji:itemFrame:)]) {
        [self.delegate emojiCollectionViewCell:self showEmojiPreviewViewWithEmoji:item.emojiObj itemFrame:item.frame];
    }
}

- (void)hidePreviewViewWithItem:(TMSEmojiItem *)item sendEmoji:(BOOL)isSend
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(emojiCollectionViewCellHideEmojiPreviewView:)]) {
        [self.delegate emojiCollectionViewCellHideEmojiPreviewView:self];
    }
    if (isSend) {
        self.sendActionBlock(item.emojiObj);
    }
}

@end

@interface TMSCustomStickerCollectionViewCell ()
@property (nonatomic, strong) UIView *customEmojiContainer;
@property (nonatomic, strong) TMSEmoji *customEmoji;
@property (nonatomic, strong) TMSEmojiItem *lastPressItem; // 上次长按的item，取消高亮试图
@end

@implementation TMSCustomStickerCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self == [super initWithFrame:frame]) {
        
        UIView *customEmojiContainer = [[UIView alloc] init];
        [self.contentView addSubview:customEmojiContainer];
        self.customEmojiContainer = customEmojiContainer;
        [customEmojiContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, cellPadding, 0, cellPadding));
        }];
        
        WS(self)
        CGFloat itemW = (SCREEN_WIDTH - 2*cellPadding) / customStickerRowCount;
        TMSEmojiItem *lastView = nil;
        NSInteger count = customStickerRow * customStickerRowCount;
        NSMutableArray *itemArray = [NSMutableArray array];
        for (NSInteger i = 0; i < count; i++) {
            
            TMSEmojiItem *item = [[TMSEmojiItem alloc] initWithSTEmojiType:TMSEmojiTypeCustom];
            UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressEmoji:)];
            longPressRecognizer.minimumPressDuration = 0.2;
            [item addGestureRecognizer:longPressRecognizer];
            item.sendActionBlock = ^(id emoji) {
                weakSelf.sendActionBlock(emoji);
            };
            [customEmojiContainer addSubview:item];
            if (lastView) {
                if (i % customStickerRowCount == 0) {
                    [item mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.equalTo(customEmojiContainer);
                        make.top.equalTo(lastView.mas_bottom);
                        make.size.mas_equalTo(CGSizeMake(itemW, self.frame.size.height*0.4));
                    }];
                } else {
                    [item mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.equalTo(lastView.mas_right);
                        make.top.equalTo(lastView);
                        make.size.mas_equalTo(CGSizeMake(itemW, self.frame.size.height*0.4));
                    }];
                }
            } else {
                [item mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.top.equalTo(customEmojiContainer);
                    make.size.mas_equalTo(CGSizeMake(itemW, self.frame.size.height*0.4));
                }];
            }
            lastView = item;
            [itemArray addObject:item];
        }
        self.emojiItems = itemArray.copy;
    }
    return self;
}

- (void)configEmojiWithEmoji:(TMSEmoji *)customEmoji showSlider:(BOOL)showSlider {
    
    _customEmoji = customEmoji;
    
    CGFloat itemW = (SCREEN_WIDTH - 2*cellPadding) / customStickerRowCount;
    CGFloat itemH = showSlider ? self.frame.size.height*0.4 : self.frame.size.height*0.5;
    
    [self.customEmojiContainer.subviews enumerateObjectsUsingBlock:^(__kindof TMSEmojiItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(itemW, itemH));
        }];
        if (idx < customEmoji.emojis.count) {
            [obj setupContentViewWithEmoji:customEmoji.emojis[idx] showSlider:showSlider];
        } else {
            [obj setupContentViewWithEmoji:nil showSlider:showSlider];
        }
    }];
}

- (void)didLongPressEmoji:(UILongPressGestureRecognizer *)recognizer
{
    if (!self.emojiItems || !self.emojiItems.count) {
        return;
    }
    
    TMSEmojiItem *item = nil;
    CGPoint point = [recognizer locationInView:self];
    for (NSUInteger i = 0, max = self.emojiItems.count; i < max; i++) {
        if (CGRectContainsPoint(self.emojiItems[i].frame, point)) {
            if (i < self.emojiItems.count) {
                item = self.emojiItems[i];
            }
            break;
        }
    }
    
    TMSCustomEmoji *customEmoji = (TMSCustomEmoji *)item.emojiObj;
    if ([customEmoji.pic isEqualToString:@"local"]) {
        [self hideHighlightedViewWithItem:nil sendSticker:NO];
        return;
    }

    if (customEmoji.pic.length == 0) {
        [self hideHighlightedViewWithItem:nil sendSticker:NO];
        return;
    }
    
    if (self.lastPressItem != item) {
        [self.lastPressItem highlightedViewVisiable:NO];
        [item highlightedViewVisiable:YES];
        self.lastPressItem = item;
    }
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            [self showPreviewViewWithItem:item];
            break;
        case UIGestureRecognizerStateChanged:
            [self showPreviewViewWithItem:item];
            break;
        case UIGestureRecognizerStateEnded:
            [self hideHighlightedViewWithItem:item sendSticker:YES];
            break;
        default:
            [self hideHighlightedViewWithItem:item sendSticker:NO];
            break;
    }
}

- (void)showPreviewViewWithItem:(TMSEmojiItem *)item
{
    if (!item) {
        [self hidePreviewView];
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(emojiCollectionViewCell:showEmojiPreviewViewWithEmoji:itemFrame:)]) {
        [self.delegate emojiCollectionViewCell:self showEmojiPreviewViewWithEmoji:item.emojiObj itemFrame:item.frame];
    }
}

- (void)hidePreviewView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(emojiCollectionViewCellHideEmojiPreviewView:)]) {
        [self.delegate emojiCollectionViewCellHideEmojiPreviewView:self];
    }
}

- (void)hideHighlightedViewWithItem:(TMSEmojiItem *)item sendSticker:(BOOL)isSend {
    
    TMSEmojiItem *tempItem = item ? item : self.lastPressItem;
    
    if (isSend) {
        self.sendActionBlock(tempItem.emojiObj);
    }
    [self hidePreviewView];
    [tempItem highlightedViewVisiable:NO];
    self.lastPressItem = nil;
    
}

@end
