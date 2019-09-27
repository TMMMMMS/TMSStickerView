//
//  TMSInputView.m
//  TMSStickerView
//
//  Created by TMS on 2019/1/17.
//  Copyright © 2019年 TMS. All rights reserved.
//

#import "TMSInputView.h"
#import "AppDelegate.h"
#import <Masonry.h>
#import "TMSStickerView.h"
#import <IQKeyboardManager.h>

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)

@interface TMSInputView ()<UITextViewDelegate, TMSEmojiViewDelegate>
@property (nonatomic, assign) UIEdgeInsets safeAreaInsets;
@property (nonatomic, strong) UIButton *stickerBtn;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) TMSStickerView *stickerView;
@property (nonatomic, strong) UITapGestureRecognizer *textViewTap;
@end

@implementation TMSInputView

- (instancetype)init {
    
    if (self == [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        [self configViews];
        self.textViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backToTextInput)];
    }
    return self;
}

- (void)stickerButttonBackToOriginalState {
    
    [self.textView resignFirstResponder];
    self.stickerBtn.selected = NO;
    self.textView.inputView = nil;
    [self.textView removeGestureRecognizer:self.textViewTap];
}

- (void)backToTextInput {
    [self btnAction:self.stickerBtn];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

- (void)removeFromSuperview
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}

- (void)sendCustomEmojiItem:(TMSCustomEmoji *)emojiItem {
    
    NSLog(@"发送自定义表情");
}

- (void)textDidChanged:(NSNotification *)info {
    
    CGFloat oldHeight = self.textView.frame.size.height;
    CGFloat newHeight = [self.textView sizeThatFits:CGSizeMake(self.textView.frame.size.width, CGFLOAT_MAX)].height;
    if (oldHeight != newHeight) {
        self.textView.scrollEnabled = newHeight > 72;
        [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(MIN(MAX(30, newHeight), 70));
        }];
        [self layoutIfNeeded];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if ([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        NSLog(@"发送了");
        textView.text = nil;
        [self textDidChanged:nil];
        return NO;
    }
    
    return YES;
}

- (void)btnAction:(UIButton *)sender {
    
    [self.textView resignFirstResponder];
    
    sender.selected = !sender.selected;
    
    if (sender.selected) { // 显示表情键盘

        __weak typeof(self) weakSelf = self;
        self.stickerView.sendActionBlock = ^(id emoji) {
            NSLog(@"%@", weakSelf.textView.text);
        };
        [self.stickerView setTextView:self.textView];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.textView addGestureRecognizer:self.textViewTap];
        });
    } else {
        self.textView.inputView = nil;
        [self.textView removeGestureRecognizer:self.textViewTap];
    }

    [self.textView becomeFirstResponder];
}

#pragma mark - Initialize
- (void)configViews {
    
    UITextView *textView = [[UITextView alloc] init];
    textView.textContainerInset = UIEdgeInsetsZero;
    textView.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1];
    textView.font = [UIFont systemFontOfSize:14];
    textView.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1];;
    textView.tintColor = [UIColor orangeColor];
    textView.scrollEnabled = NO;
    textView.layer.cornerRadius = 15;
    textView.textContainerInset = UIEdgeInsetsMake(9, 9, 7, 6);
    textView.delegate = self;
    textView.returnKeyType = UIReturnKeySend;
    textView.enablesReturnKeyAutomatically = YES;
    [self addSubview:textView];
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@6);
        make.left.equalTo(@15);
        make.right.equalTo(@-55);
        make.height.equalTo(@35);
        
        make.bottom.equalTo(@(-5-self.safeAreaInsets.bottom));
    }];
    self.textView = textView;

    UIButton *stickerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [stickerBtn setBackgroundImage:[UIImage imageNamed:@"smile"] forState:UIControlStateNormal];
    [stickerBtn setBackgroundImage:[UIImage imageNamed:@"smile_sel"] forState:UIControlStateSelected];
    [stickerBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:stickerBtn];
    self.stickerBtn = stickerBtn;
    [stickerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-15);
        make.bottom.equalTo(textView).offset(-4);
        make.size.mas_equalTo(CGSizeMake(25, 25));
    }];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:238.0/255.0 blue:245.0/255.0 alpha:1];
    [self addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.equalTo(@0.5);
    }];
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

- (TMSStickerView *)stickerView {
    
    if (!_stickerView) {
        //        if (_hideCustomEmoji) {
        //            _stickerView = [TMSStickerView showEmojiViewWithoutCustomEmoji];
        //        } else {
        //            _stickerView = [TMSStickerView showEmojiView];
        //        }
        _stickerView = [TMSStickerView showEmojiView];
        _stickerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 190 + self.safeAreaInsets.bottom + 5);
    }
    _stickerView.delegate = self;
    
    return _stickerView;
}


@end
