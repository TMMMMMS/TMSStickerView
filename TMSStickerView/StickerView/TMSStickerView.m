//
//  TMSStickerView.m
//  TMSStickerView
//
//  Created by TMS on 2019/1/15.
//  Copyright © 2019年 TMS. All rights reserved.
//

#import "TMSStickerView.h"
#import "AppDelegate.h"
#import <Masonry.h>
#import "TMSEmoji.h"
#import "TMSEmojiViewConst.h"
#import "TMSStickerCollectionViewCell.h"
#import "TMSEmojiPreviewView.h"
#import "TMSCustomStickerPreviewView.h"
#import "UIImage+Effect.h"

#define WS(object)  __weak __typeof(object) weakSelf = object;
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define customStickerRowCount ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 8 : 4)

@interface TMSEmojiToolBar : UIView
@property (nonatomic, assign) BOOL beginDelete;
@property (nonatomic, assign) CGFloat time;
@property (nonatomic, strong) NSMutableArray *emojiButtons;
@property (assign, nonatomic) TMSEmojiType showType;

+ (instancetype)toolBarWithEmojis:(NSArray *)emojis isHideCustomEmoji:(BOOL)isHide;
- (void)setCurrentSelectedTooItemWithEmojiString:(NSString *)emojiString;
- (void)setItemsInitialState;

@property (strong, nonatomic) void (^actionHandler)(TMSEmojiType emojiType);
@property (strong, nonatomic) void (^deleteHandler)(void);
@property (nonatomic,copy) void (^sendActionBlock)(void);
@property (nonatomic, assign) BOOL isHideCustomEmoji;
@end

@implementation TMSEmojiToolBar{
    NSArray *_emojis;
    UIButton *sendButton;
    UIButton *deleteButton;
}

+ (instancetype)toolBarWithEmojis:(NSArray *)emojis isHideCustomEmoji:(BOOL)isHide {
    
    TMSEmojiToolBar *toolBar = [[TMSEmojiToolBar alloc] initHideCustomEmoji:isHide];
    return toolBar;
}

- (instancetype)initHideCustomEmoji:(BOOL)isHide{
    if (self = [super init]){
        self.backgroundColor = [UIColor whiteColor];
        self.isHideCustomEmoji = isHide;
        self.beginDelete = NO;
        self.showType = TMSEmojiTypePeople;
        [self configViews];
    }
    return self;
}

- (void)setCurrentSelectedTooItemWithEmojiString:(NSString *)emojiString {
    
    TMSEmojiType emojiType = [self emojiTypeWithString:emojiString];
    
    if (self.showType == emojiType) {
        return;
    }
    [self.emojiButtons enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *btn = (UIButton *)obj;
        NSString *currentTitle = btn.currentTitle;
        btn.selected = [currentTitle isEqualToString:emojiString];
    }];
    self.showType = emojiType;
    
}

- (void)setItemsInitialState {
    
    [self.emojiButtons enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *btn = (UIButton *)obj;
        btn.selected = idx == 0;
        if (idx == 0) {
            self.showType = [self emojiTypeWithString:btn.currentTitle];
        }
    }];
}

- (void)emojiButtonTouchDown:(UIButton *)sender {
    
    if (self.showType == [self emojiTypeWithString:sender.currentTitle]) {
        return;
    }
    
    [self.emojiButtons enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *btn = (UIButton *)obj;
        btn.selected = NO;
    }];
    sender.selected = YES;
    if (self.actionHandler){
        self.actionHandler([self emojiTypeWithString:sender.currentTitle]);
    }
}

- (void)deleteButtonTouchDown{
    if (self.deleteHandler){
        self.deleteHandler();
        self.beginDelete = YES;
        self.time = 0.3;
        [self deleteDown];
    }
}

- (void)deleteCancel{
    self.beginDelete = NO;
}

- (void)deleteDown{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.beginDelete){
            if (self.deleteHandler){
                self.deleteHandler();
            }
            self.time = 0.1;
            [self deleteDown];
        }
    });
}

- (void)sendButtonClick {
    
    self.sendActionBlock();
}

- (void)configViews{
    
    self.emojiButtons = [NSMutableArray array];
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.backgroundColor = [UIColor clearColor];
    sendButton.layer.cornerRadius = 12.5;
    sendButton.layer.masksToBounds = YES;
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendButton setBackgroundColor:[UIColor colorWithRed:18.0/255.0 green:150.0/255.0 blue:219.0/255.0 alpha:1]];
    sendButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [sendButton addTarget:self action:@selector(sendButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sendButton];
    [sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@7);
        make.right.equalTo(@-13);
        make.size.mas_equalTo(CGSizeMake(50, 25));
    }];
    
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [deleteButton setImage:[[UIImage imageNamed:@"icon_deleFace"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]  forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deleteButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [deleteButton addTarget:self action:@selector(deleteCancel) forControlEvents:UIControlEventTouchUpInside];
    [deleteButton addTarget:self action:@selector(deleteCancel) forControlEvents:UIControlEventTouchDragOutside];
    [self addSubview:deleteButton];
    [deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(sendButton);
        make.right.equalTo(sendButton.mas_left).offset(-15);
        make.size.mas_equalTo(CGSizeMake(28, 22));
    }];
    
    UIButton *lastBtn = nil;
    for (TMSEmoji *emoji in [self createEmojiButtons]){
        UIButton *emojiButton = [self getButton:CGRectZero title:emoji.title];
        if (!lastBtn) {
            emojiButton.selected = YES;
        }
        [self.emojiButtons addObject:emojiButton];
        [self addSubview:emojiButton];
        if (lastBtn) {
            [emojiButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(lastBtn.mas_right).offset(10);
                make.top.equalTo(lastBtn);
            }];
        } else {
            [emojiButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@15);
                make.centerY.equalTo(sendButton);
            }];
        }
        lastBtn = emojiButton;
    }
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:238.0/255.0 blue:245.0/255.0 alpha:1];
    [self addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.height.equalTo(@0.5);
    }];
}

- (void)btnAction:(UIButton *)sender{
    sender.highlighted = NO;
}

- (UIButton *)getButton:(CGRect)frame title:(NSString *)title
{
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:18.0/255.0 green:150.0/255.0 blue:219.0/255.0 alpha:1] forState:UIControlStateSelected];
    [button setTitle:title forState:UIControlStateNormal];
    [button titleLabel].font = [UIFont systemFontOfSize:12];
    [button addTarget:self action:@selector(emojiButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (NSArray *)createEmojiButtons {
    
    NSMutableArray *titlesArray = [NSMutableArray array];
    if (!self.isHideCustomEmoji) {
        TMSEmoji *emoji = [[TMSEmoji alloc] init];
        emoji.type = TMSEmojiTypePeople;
        emoji.title = @"普通";
        [titlesArray addObject:emoji];
        emoji = [[TMSEmoji alloc] init];
        emoji.type = TMSEmojiTypeFlower;
        emoji.title = @"自定义";
        [titlesArray addObject:emoji];
    } else {
        TMSEmoji *emoji = [[TMSEmoji alloc] init];
        emoji.type = TMSEmojiTypePeople;
        emoji.title = @"人物";
        [titlesArray addObject:emoji];
        emoji = [[TMSEmoji alloc] init];
        emoji.type = TMSEmojiTypeFlower;
        emoji.title = @"自然";
        [titlesArray addObject:emoji];
        emoji = [[TMSEmoji alloc] init];
        emoji.type = TMSEmojiTypeBell;
        emoji.title = @"日常";
        [titlesArray addObject:emoji];
        emoji = [[TMSEmoji alloc] init];
        emoji.type = TMSEmojiTypeVehicle;
        emoji.title = @"旅行";
        [titlesArray addObject:emoji];
        emoji = [[TMSEmoji alloc] init];
        emoji.type = TMSEmojiTypeNumber;
        emoji.title = @"符号";
        [titlesArray addObject:emoji];
    }
    
    return titlesArray.copy;
}

- (TMSEmojiType)emojiTypeWithString:(NSString *)string {
    
    if ([string isEqualToString:@"普通"] || [string isEqualToString:@"人物"]) {
        return TMSEmojiTypePeople;
    } else if ([string isEqualToString:@"自然"]) {
        return TMSEmojiTypeFlower;
    } else if ([string isEqualToString:@"日常"]) {
        return TMSEmojiTypeBell;
    } else if ([string isEqualToString:@"旅行"]) {
        return TMSEmojiTypeVehicle;
    } else if ([string isEqualToString:@"符号"]) {
        return TMSEmojiTypeNumber;
    } else {
        return TMSEmojiTypeCustom;
    }
}

@end

@interface TMSStickerView ()<UICollectionViewDelegate, UICollectionViewDataSource, CAAnimationDelegate, TMSStickerCollectionViewCellDelegate>
@property (nonatomic, assign) UIEdgeInsets safeAreaInsets;
@property(nonatomic, strong) TMSEmojiToolBar *toolBar;
@property (nonatomic, strong) TMSEmojiPreviewView *emojiPreviewView;
@property (nonatomic, strong) TMSCustomStickerPreviewView *customSickerPreviewView;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataSource;

@property(nonatomic, strong) UISlider *emojiSlider;
// 自定义表情起始index
@property (nonatomic, assign) NSInteger customEmojiStartIndex;
@property (nonatomic, assign) BOOL hideCustomEmoji;

@property (nonatomic, assign) BOOL isAnimationing;

@property (nonatomic, assign) CGFloat lastContentOffsetX;

// 用户slider的CAAnimation
@property (nonatomic, assign) CGRect sliderOriginRect;

/** 自定义表情分类上次选择index，用于回显 */
@property (nonatomic, assign) NSInteger customSelectedIndex;
/** normal表情分类上次选择index，用于回显 */
@property (nonatomic, assign) NSInteger normalSelectedIndex;
@end

@implementation TMSStickerView

+ (instancetype)showEmojiView{
    
    static dispatch_once_t onceToken;
    static TMSStickerView *_emojiView;
    dispatch_once(&onceToken, ^{
        _emojiView = [[self alloc] initWithCustomEmoji:NO];
    });
    return _emojiView;
}

+ (instancetype)showEmojiViewWithoutCustomEmoji {
    
    static dispatch_once_t onceToken;
    static TMSStickerView *_emojiView;
    dispatch_once(&onceToken, ^{
        _emojiView = [[self alloc] initWithCustomEmoji:YES];
    });
    return _emojiView;
}

- (instancetype)initWithCustomEmoji:(BOOL)hideCustomEmoji {
    if (self = [super init]){
        self.hideCustomEmoji = hideCustomEmoji;
        self.clipsToBounds = NO;
        self.backgroundColor = [UIColor whiteColor];
        [self configViews];
        
        [self reloadDatasWithCustomEmoji:hideCustomEmoji];
    }
    return self;
}

- (void)initialState {
    
    self.customSelectedIndex = 0;
    self.normalSelectedIndex = 0;
    [self.emojiSlider setValue:0 animated:YES];
    self.emojiSlider.alpha = 0;
    [self.collectionView setContentOffset:CGPointZero animated:NO];
    [self.toolBar setItemsInitialState];
}

- (void)reloadDatasWithCustomEmoji:(BOOL)hideCustomEmoji {
    
    NSMutableArray *dataSource = [NSMutableArray array];
    [self setupDataSource:dataSource customEmoji:hideCustomEmoji];
    
    if (!hideCustomEmoji) { // 接收到服务器端的自定义表情数据，刷新整个表情控件
        
//        WS(self)
//        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:TMSCustomEmojiShouldRefreshNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification *x) {
//
//            NSMutableArray *tempDataSource = [NSMutableArray array];
//            [weakSelf setupDataSource:tempDataSource customEmoji:NO];
//            weakSelf.dataSource  = tempDataSource.copy;
//            [weakSelf.collectionView reloadData];
//        }];
    }
    self.dataSource  = dataSource.copy;
    [self.collectionView reloadData];
}

- (void)setupDataSource:(NSMutableArray *)dataSource customEmoji:(BOOL)hideCustomEmoji  {
    
    if (hideCustomEmoji) {
        [dataSource addObjectsFromArray:[TMSEmoji allEmojisWithoutCustomEmoji]];
    } else {
        NSArray *customArray = [self handleCustomEmojiData];
        self.emojiSlider.hidden = customArray.count <= 2;
        
        [dataSource addObjectsFromArray:[TMSEmoji allEmojis]];
        [dataSource addObjectsFromArray:customArray];
        self.emojiSlider.maximumValue = customArray.count - 1;
        
        [dataSource enumerateObjectsUsingBlock:^(TMSEmoji *emoji, NSUInteger idx, BOOL * _Nonnull stop) {
            if (emoji.type == TMSEmojiTypeCustom) {
                self.customEmojiStartIndex = idx;
                *stop = YES;
            }
        }];
    }
}

- (void)setTextView:(id<UITextInput>)textView{
    if ([textView isKindOfClass:[UITextView class]]) {
        [(UITextView *)textView setInputView:self];
    }
    else if ([textView isKindOfClass:[UITextField class]]) {
        [(UITextField *)textView setInputView:self];
    }
    _textView = textView;
}

- (void)insertEmoji:(NSString *)emoji{
    [[UIDevice currentDevice] playInputClick];
    [self.textView insertText:emoji];
    [self textChanged];
}

- (void)textChanged{
    if ([self.textView isKindOfClass:[UITextView class]])
        [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:self.textView];
    else if ([self.textView isKindOfClass:[UITextField class]])
        [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:self.textView];
}

#pragma mark - 获取自定义表情
- (NSArray *)handleCustomEmojiData {

    // 自定义表情通过服务器请求过后，会保存在本地一份，通过通知来刷新自定义表情的数据
    NSMutableArray *tempCustomArray = [NSMutableArray arrayWithArray:[TMSCustomEmoji allEmojis]];
    TMSCustomEmoji *addEmoji = [[TMSCustomEmoji alloc] init];
    addEmoji.pic = @"local";
    [tempCustomArray insertObject:addEmoji atIndex:0];

    NSInteger cellCount = customStickerRow * customStickerRowCount;
    NSMutableArray *tempDataSource = [NSMutableArray array];
    NSMutableArray *tempEmojiArray = [NSMutableArray array];
    for (NSInteger i = 0; i < tempCustomArray.count; i++) {
        if (i % cellCount == 0) {

            if (tempEmojiArray.count) {
                TMSEmoji *emoji = [TMSEmoji new];
                emoji.title = @"自定义";
                emoji.emojis = tempEmojiArray.copy;
                emoji.type = TMSEmojiTypeCustom;
                [tempDataSource addObject:emoji];
            }

            [tempEmojiArray removeAllObjects];

            if (i == tempCustomArray.count - 1) {
                [tempEmojiArray addObject:tempCustomArray[i]];
                TMSEmoji *emoji = [TMSEmoji new];
                emoji.title = @"自定义";
                emoji.emojis = tempEmojiArray.copy;
                emoji.type = TMSEmojiTypeCustom;
                [tempDataSource addObject:emoji];
            }

        } else if (i == tempCustomArray.count - 1) {
            [tempEmojiArray addObject:tempCustomArray[i]];
            TMSEmoji *emoji = [TMSEmoji new];
            emoji.title = @"自定义";
            emoji.emojis = tempEmojiArray.copy;
            emoji.type = TMSEmojiTypeCustom;
            [tempDataSource addObject:emoji];

        }
        [tempEmojiArray addObject:tempCustomArray[i]];
    }

    return tempDataSource.copy;
    
}

#pragma mark - slider的事件
- (void)sliderbutton:(UISlider *)sender{
    
    NSUInteger index = (NSUInteger)(sender.value + 0.5);
    self.customSelectedIndex = index;
    [self.emojiSlider setValue:index animated:YES];
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:(self.customEmojiStartIndex+index) inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TMSEmoji *emojiModel = self.dataSource[indexPath.row];
    
    WS(self)
    if (emojiModel.type != TMSEmojiTypeCustom) {
        TMSStickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(TMSStickerCollectionViewCell.class) forIndexPath:indexPath];
        cell.sendActionBlock = ^(id emoji) {
            if ([emoji isKindOfClass:[NSString class]]) {
                [weakSelf insertEmoji:emoji];
            }
        };
        cell.systemEmoji = emojiModel;
        
        cell.delegate = self;
        
        return cell;
    } else {
        TMSCustomStickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(TMSCustomStickerCollectionViewCell.class) forIndexPath:indexPath];
        cell.sendActionBlock = ^(id emoji) {
            if ([weakSelf.delegate respondsToSelector:@selector(sendCustomEmojiItem:)]) {
                [weakSelf.delegate sendCustomEmojiItem:emoji];
            }
        };
        
        cell.delegate = self;
        
        [cell configEmojiWithEmoji:emojiModel showSlider:!self.emojiSlider.hidden];
        
        return cell;
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    //    if (self.lastContentOffsetX < scrollView.contentOffset.x) {
    //        NSLog(@"向左滚动");
    //    }else{
    //        NSLog(@"向右滚动");
    //    }
    
    CGFloat fIdx = (scrollView.contentOffset.x + SCREEN_WIDTH * 0.2) / SCREEN_WIDTH;
    NSInteger index = (NSInteger)fIdx;
    if (index >= self.dataSource.count) {
        return;
    }
    
    TMSEmoji *emojiModel = self.dataSource[index];
    [self.toolBar setCurrentSelectedTooItemWithEmojiString:emojiModel.title];
    if (index+1 >= self.dataSource.count) {
        if (emojiModel.type == TMSEmojiTypeCustom) {
            [self.emojiSlider setValue:(scrollView.contentOffset.x / SCREEN_WIDTH - self.customEmojiStartIndex) animated:YES];
        }
        return;
    }
    
    TMSEmoji *nextEmoji = self.dataSource[index+1];
    
    if (emojiModel.type == nextEmoji.type) {
        if (emojiModel.type == TMSEmojiTypeCustom) {
            [self.emojiSlider setValue:(scrollView.contentOffset.x / SCREEN_WIDTH - self.customEmojiStartIndex) animated:YES];
        }
        return;
    }
    
    if (nextEmoji.type == TMSEmojiTypeCustom) {
        
        if (self.isAnimationing) {
            return;
        }
        
        // 左滑 消失
        /*
         右滑 显示
         1.在custom上右滑
         2.从people上右滑
         */
        if (self.lastContentOffsetX > scrollView.contentOffset.x) { // 右滑
            
            if (self.emojiSlider.alpha != 0) {
                
                [self sliderAnimationWithState:NO];
            }
            
        } else {
            
            if (scrollView.contentOffset.x >= (self.customEmojiStartIndex - 0.3) * SCREEN_WIDTH) {
                
                if (self.emojiSlider.alpha != 1) {
                    
                    self.emojiSlider.alpha = 1;
                    
                    [self sliderAnimationWithState:YES];
                    
                }
            }
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if (self.hideCustomEmoji || self.emojiSlider.hidden) {
        return;
    }
    
    self.lastContentOffsetX = scrollView.contentOffset.x;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (self.hideCustomEmoji || self.emojiSlider.hidden) {
        return;
    }
    
    NSInteger index = scrollView.contentOffset.x / SCREEN_WIDTH;
    
    TMSEmoji *emoji = self.dataSource[index];
    if (emoji.type == TMSEmojiTypeCustom) {
        
        self.customSelectedIndex = index - self.customEmojiStartIndex > 0 ? index - self.customEmojiStartIndex : 0;
        
        if (self.emojiSlider.alpha == 0) {
            
            if (self.isAnimationing) {
                return;
            }
            
            self.emojiSlider.alpha = 1;
            
            [self sliderAnimationWithState:YES];
            
        }
    } else {
        
        self.normalSelectedIndex = index;
        
        if (self.emojiSlider.alpha == 1) {
            
            [self sliderAnimationWithState:NO];
        }
    }
    
}

#pragma mark - TMSEmojiCollectionViewCell
- (void)emojiCollectionViewCell:(TMSStickerCollectionViewCell *)emojiCollectionViewCell showEmojiPreviewViewWithEmoji:(id)emoji itemFrame:(CGRect)itemFrame {
    
    if (!emoji) {
        return;
    }
    
    CGFloat cellPadding = 10;
    
    UIView *previewView = nil;
    if ([emojiCollectionViewCell isKindOfClass:[TMSCustomStickerCollectionViewCell class]]) {
        
        self.customSickerPreviewView.emojiObj = emoji;
        previewView = self.customSickerPreviewView;
        
        CGRect itemFrameAtKeybord = CGRectMake(itemFrame.origin.x, itemFrame.origin.y, itemFrame.size.width, itemFrame.size.height);
        CGFloat previewX = CGRectGetMidX(itemFrameAtKeybord) - TMSCustomPreviewViewWidth / 2 + cellPadding;
        CGFloat previewY = SCREEN_HEIGHT - CGRectGetHeight(self.bounds) - TMSCustomPreviewViewHeight - 1.5 + CGRectGetMinY(itemFrameAtKeybord) + 10;
        
        NSInteger arrowPosition = TMSCustomStickerLocationTypeCenter;
        if (previewX < 10) {
            previewX = 10;
            arrowPosition = TMSCustomStickerLocationTypeLeft;
        } else if (previewX + TMSCustomPreviewViewWidth > SCREEN_WIDTH - 10) {
            previewX = SCREEN_WIDTH - 10 - TMSCustomPreviewViewWidth;
            arrowPosition = TMSCustomStickerLocationTypeRight;
        } else {
            arrowPosition = TMSCustomStickerLocationTypeCenter;
        }
        
        self.customSickerPreviewView.frame = CGRectMake(previewX, previewY, TMSCustomPreviewViewWidth, TMSCustomPreviewViewHeight);
        self.customSickerPreviewView.position = arrowPosition;
        [self.customSickerPreviewView setNeedsDisplay];
        
    } else {
        
        self.emojiPreviewView.emojiObj = emoji;
        previewView = self.emojiPreviewView;
        
        CGRect itemFrameAtKeybord = CGRectMake(itemFrame.origin.x, TMSStickerTopInset + itemFrame.origin.y, itemFrame.size.width, itemFrame.size.height);
        CGFloat previewW = CGRectGetMidX(itemFrameAtKeybord) - TMSPreviewViewWidth / 2 + cellPadding;
        CGFloat previewH = SCREEN_HEIGHT - CGRectGetHeight(self.bounds) + CGRectGetMaxY(itemFrameAtKeybord) - TMSPreviewViewHeight - 8;
        self.emojiPreviewView.frame = CGRectMake(previewW, previewH, TMSPreviewViewWidth, TMSPreviewViewHeight);
    }
    
    UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
    if (window) {
        [window addSubview:previewView];
    }
}

- (void)emojiCollectionViewCellHideEmojiPreviewView:(TMSStickerCollectionViewCell *)emojiCollectionViewCell {
    
    [self.emojiPreviewView removeFromSuperview];
    [self.customSickerPreviewView removeFromSuperview];
}

#pragma mark - Animation
- (void)sliderAnimationWithState:(BOOL)isShow {
    
    NSString *key = isShow ? @"showAnimation" : @"hideAnimation";
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"position.y"];
    anim.duration = 0.15;
    anim.repeatCount = 1;
    
    if (isShow) {
        anim.fromValue = @(206 + self.safeAreaInsets.bottom);
        anim.toValue = @(self.sliderOriginRect.origin.y+25);
    } else {
        anim.toValue = @(206 + self.safeAreaInsets.bottom);
    }
    
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    anim.delegate = self;
    [self.emojiSlider.layer addAnimation:anim forKey:key];
}

#pragma mark CAAnimationDelegate
- (void)animationDidStart:(CAAnimation *)anim {
    
    self.isAnimationing = YES;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    if (anim == [self.emojiSlider.layer animationForKey:@"hideAnimation"]) {
        self.emojiSlider.alpha = 0;
    }
    if (flag) {
        [self.emojiSlider.layer removeAllAnimations];
        self.isAnimationing = NO;
    }
}

#pragma mark - Initialize
- (void)configViews {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(SCREEN_WIDTH, itemH*emojiRow);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerClass:[TMSStickerCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass(TMSStickerCollectionViewCell.class)];
    [self.collectionView registerClass:[TMSCustomStickerCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass(TMSCustomStickerCollectionViewCell.class)];
    [self addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(@5);
        make.height.equalTo(@(emojiRow*itemH));
    }];
    
    __weak __typeof(self) weakSelf = self;
    TMSEmojiToolBar *toolBar = [TMSEmojiToolBar toolBarWithEmojis:self.dataSource isHideCustomEmoji:self.hideCustomEmoji];
    toolBar.actionHandler = ^(TMSEmojiType emojiType) {
        
        if (weakSelf.hideCustomEmoji) {
            NSInteger currentIndex = weakSelf.collectionView.contentOffset.x / SCREEN_WIDTH;
            TMSEmoji *emoji = weakSelf.dataSource[currentIndex];
            if (emoji.type == emojiType) {
                return ;
            }
        }
        
        [weakSelf.dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            TMSEmoji *emoji = weakSelf.dataSource[idx];
            if (emoji.type == emojiType) { // 找到属于该分类表情的第一页所属的index
                
                if (emojiType == TMSEmojiTypeCustom) {
                    idx = idx + weakSelf.customSelectedIndex;
                } else {
                    if (!weakSelf.hideCustomEmoji) {
                        idx = weakSelf.normalSelectedIndex;
                    }
                }
                
                [weakSelf.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
                weakSelf.emojiSlider.alpha = emojiType == TMSEmojiTypeCustom ? 1 : 0;
                [weakSelf.emojiSlider setValue:weakSelf.customSelectedIndex animated:YES];
                *stop = YES;
            }
        }];
    };
    toolBar.sendActionBlock = ^{
        if (weakSelf.sendActionBlock) {
            weakSelf.sendActionBlock(nil);
        }
    };
    toolBar.deleteHandler = ^{
        [weakSelf deletePressed];
    };
    [self addSubview:toolBar];
    self.toolBar = toolBar;
    [toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.collectionView.mas_bottom);
        make.height.equalTo(@(40+self.safeAreaInsets.bottom));
    }];
    
    UIImage *icon = [UIImage imageWithSize:CGSizeMake(15, 15) scale:[UIScreen mainScreen].scale color:[UIColor colorWithRed:18.0/255.0 green:150.0/255.0 blue:219.0/255.0 alpha:1]];
    self.emojiSlider = [[UISlider alloc] init];
    self.emojiSlider.hidden = YES;
    self.emojiSlider.alpha = 0;
    self.emojiSlider.minimumValue = 0.0;
    self.emojiSlider.maximumValue = 0;
    self.emojiSlider.value = 0;
    self.emojiSlider.minimumTrackTintColor = [UIColor colorWithRed:18.0/255.0 green:150.0/255.0 blue:219.0/255.0 alpha:1];
    self.emojiSlider.maximumTrackTintColor = [UIColor colorWithRed:191.0/255.0 green:191.0/255.0 blue:191.0/255.0 alpha:0.7];
    [self.emojiSlider setThumbImage:[icon imageWithRoundedCornerRadius:7.5] forState:UIControlStateNormal];
    [self.emojiSlider addTarget:self action:@selector(sliderbutton:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.emojiSlider];
    [self.emojiSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.toolBar.mas_top).offset(13);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH * 0.85, 50));
    }];
    
    [self bringSubviewToFront:self.toolBar];
    
}

- (TMSEmojiPreviewView *)emojiPreviewView {
    
    if (!_emojiPreviewView) {
        _emojiPreviewView = [[TMSEmojiPreviewView alloc] init];
    }
    return _emojiPreviewView;
}

- (TMSCustomStickerPreviewView *)customSickerPreviewView {
    
    if (!_customSickerPreviewView) {
        _customSickerPreviewView = [[TMSCustomStickerPreviewView alloc] init];
        _customSickerPreviewView.backgroundColor = [UIColor clearColor];
    }
    return _customSickerPreviewView;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    self.sliderOriginRect = self.emojiSlider.frame;
}

- (void)deletePressed{
    [self.textView deleteBackward];
    [[UIDevice currentDevice] playInputClick];
    [self textChanged];
}

- (UIEdgeInsets)safeAreaInsets {
    if (@available(iOS 11.0, *)) {
        static dispatch_once_t onceToken;
        static CGFloat statusBarFrameHeight;
        dispatch_once(&onceToken, ^{
            statusBarFrameHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
        });
        if (statusBarFrameHeight == 20) {
            return UIEdgeInsetsZero;
        }
        return [AppDelegate sharedDelegate].window.safeAreaInsets;
    } else {
        return UIEdgeInsetsZero;
    }
}


@end

