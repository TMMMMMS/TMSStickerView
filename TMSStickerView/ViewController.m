//
//  ViewController.m
//  TMSStickerView
//
//  Created by TMS on 2019/1/15.
//  Copyright © 2019年 TMS. All rights reserved.
//

#import "ViewController.h"
#import "TMSInputView.h"
#import <Masonry.h>

@interface ViewController ()
@property (nonatomic, strong) TMSInputView *inputView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor orangeColor];
    
    self.inputView = [[TMSInputView alloc] init];
    [self.view addSubview:self.inputView];
    [self.inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.inputView stickerButttonBackToOriginalState];
}

@end
