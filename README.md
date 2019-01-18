# TMSStickerView

### 一款仿微信表情键盘的控件，添加长按预览、自定义表情界面滑块拖拽等功能

#### 开发中遇到的问题：
```
1. 系统emoji表情页与自定义表情页交替时，底部滑块的隐藏与显示
2. 手指从自定义表情页拖拽到emoji表情页，在不松手的情况下，又拖回自定义表情页时，底部滑块的隐藏与显示
```

##### 处理方案：
- 何时对滑块做显隐动画？
既然是交替时的特殊处理，首先在``- (void)scrollViewDidScroll:(UIScrollView *)scrollView``方法中依据collectionview当前偏移量从dataSource中取出当前展示的模型，以及下一个模型。获得两个模型后，首先判断两个表情模型(`TMSEmoji`)的类型是否相同，如果不同，则需要对滑块添加显隐的动画。

- 对滑块是做显示动画还是隐藏动画？
当collectionview的contentOffset.x逐渐变大时，此时需要对滑块做显示动画；反之对其做隐藏动画。这里需要辨别出collectionview的滑动方向是左滑还是滑。
并且针对于上述问题2中的情形，需要在``- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView``方法中对于当前显示的item根据类型判断来控制滑块动画是否执行。

```
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
```
```
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
```
---
```
3. 按分类浏览过的表情，当点击底部分类按钮时，跳转到之前浏览过的页面
```
##### 处理方案：
声明两个属性:**customSelectedIndex**(自定义表情用户最后停留的index)和**normalSelectedIndex**(系统emoji表情用户最后停留的index)。在``- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView``方法中记录这两个值，当点击底部分类进行跳转时，遍历整个collectionview的dataSource，依据用户当前所点击的分类找到属于该分类的第一个model所处的index，在index基础上加上customSelectedIndex或者normalSelectedIndex，使用``- (void)collectionView的scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UICollectionViewScrollPosition)scrollPosition animated:(BOOL)animated``方法进行跳转

```
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
```
---

```
4. 当调出表情键盘时，单击输入框重新调出系统键盘。
```
##### 处理方案：
当展示出表情键盘时，对textView添加tap手势，在tap手势的action中重新调出系统键盘，并且移除tap手势

```
if (sender.selected) { // 显示表情键盘
    self.stickerView.sendActionBlock = ^(id emoji) {
        NSLog(@"发送emoji表情");
    };
    [self.stickerView setTextView:self.textView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.textView addGestureRecognizer:self.textViewTap];
     });
} else {
     self.textView.inputView = nil;
     [self.textView removeGestureRecognizer:self.textViewTap];
}
```
---
```
5. 表情的长按预览功能
```
##### 处理方案：
参考于**PPStickerKeyboard**的实现思路，在item上添加**UILongPressGestureRecognizer**，依据手势recognizer.state的三种状态**(UIGestureRecognizerStateBegan, UIGestureRecognizerStateChanged, UIGestureRecognizerStateEnded)**来控制标签预览层的显示与隐藏
自定义表情预览层的边框通过drawRect方法实现，考虑到drawRect对性能的影响，也可以使用**CAShapeLayer**来替换drawRect方法。
