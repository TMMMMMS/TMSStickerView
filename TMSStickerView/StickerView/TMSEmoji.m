//
//  TMSEmoji.m
//  TMSStickerView
//
//  Created by TMS on 2019/1/15.
//  Copyright © 2019年 TMS. All rights reserved.
//

#import "TMSEmoji.h"
#import <UIKit/UIKit.h>
//#import "CacheHelper.h"

#define kEmojiRow 5
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define kEmojiRowCount ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 8 : ((SCREEN_WIDTH <= 320) ? 6 : 8))

@implementation TMSEmoji

- (NSString *)description {
    
    return [NSString stringWithFormat:@"self.emojis.count:%zd", self.emojis.count];
}

@end

@implementation TMSEmoji (Generate)

+ (NSDictionary *)emojis{
    static NSDictionary *__emojis = nil;
    if (!__emojis){
        NSString *fileName = @"emoji_ios9+";
        NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
        NSData *emojiData = [[NSData alloc] initWithContentsOfFile:path];
        __emojis = [NSJSONSerialization JSONObjectWithData:emojiData options:NSJSONReadingAllowFragments error:nil];
    }
    return __emojis;
}

+ (instancetype)recentEmoji {
    TMSEmoji *emoji = [TMSEmoji new];
    emoji.title = @"最近";
    //    emoji.emojis = [CacheHelper getValue:CacheRecentEmojis];
    //    emoji.type = STEmojiTypeRecent;
    return emoji;
}

+ (instancetype)peopleEmoji{
    TMSEmoji *emoji = [TMSEmoji new];
    emoji.title = @"人物";
    emoji.emojis = [self emojis][@"people"];
    emoji.type = TMSEmojiTypePeople;
    return emoji;
}

+ (instancetype)flowerEmoji{
    TMSEmoji *emoji = [TMSEmoji new];
    emoji.title = @"自然";
    emoji.emojis = [self emojis][@"flower"];
    emoji.type = TMSEmojiTypeFlower;
    return emoji;
}

+ (instancetype)bellEmoji{
    TMSEmoji *emoji = [TMSEmoji new];
    emoji.title = @"日常";
    emoji.emojis = [self emojis][@"bell"];
    emoji.type = TMSEmojiTypeBell;
    return emoji;
}

+ (instancetype)vehicleEmoji{
    TMSEmoji *emoji = [TMSEmoji new];
    emoji.title = @"旅行";
    emoji.emojis = [self emojis][@"vehicle"];
    emoji.type = TMSEmojiTypeVehicle;
    return emoji;
}

+ (instancetype)numberEmoji{
    TMSEmoji *emoji = [TMSEmoji new];
    emoji.title = @"符号";
    emoji.emojis = [self emojis][@"number"];
    emoji.type = TMSEmojiTypeNumber;
    return emoji;
}


+ (NSArray *)allEmojis{
    //    return [self recentEmoji];
    NSArray *array = @[[self peopleEmoji], [self flowerEmoji], [self bellEmoji], [self vehicleEmoji], [self numberEmoji]];
    
    NSMutableArray *tempArray = [NSMutableArray array];
    for (TMSEmoji *emoji in array) {
        [tempArray addObjectsFromArray:emoji.emojis];
    }
    
    NSInteger cellCount = kEmojiRow * kEmojiRowCount;
    NSMutableArray *tempDataSource = [NSMutableArray array];
    NSMutableArray *tempEmojiArray = [NSMutableArray array];
    for (NSInteger i = 0; i < tempArray.count; i++) {
        if (i % cellCount == 0) {
            
            if (tempEmojiArray.count) {
                TMSEmoji *emoji = [TMSEmoji new];
                emoji.title = @"普通";
                emoji.emojis = tempEmojiArray.copy;
                emoji.type = TMSEmojiTypePeople;
                [tempDataSource addObject:emoji];
            }
            
            [tempEmojiArray removeAllObjects];
        } else if (i == tempArray.count - 1) {
            [tempEmojiArray addObject:tempArray[i]];
            TMSEmoji *emoji = [TMSEmoji new];
            emoji.title = @"普通";
            emoji.emojis = tempEmojiArray.copy;
            emoji.type = TMSEmojiTypePeople;
            [tempDataSource addObject:emoji];
            
        }
        [tempEmojiArray addObject:tempArray[i]];
    }
    
    return tempDataSource;
}

+ (NSArray *)allEmojisWithoutCustomEmoji {
    
    //    NSMutableArray *tempArray = [NSMutableArray array];
    NSArray *array = @[[self peopleEmoji], [self flowerEmoji], [self bellEmoji], [self vehicleEmoji], [self numberEmoji]];
    
    NSInteger cellCount = kEmojiRow * kEmojiRowCount;
    NSMutableArray *tempDataSource = [NSMutableArray array];
    NSMutableArray *tempEmojiArray = [NSMutableArray array];
    for (NSInteger i = 0; i < array.count; i++) {
        
        [tempEmojiArray removeAllObjects];
        TMSEmoji *originEmoji = array[i];
        NSArray *typeArray = originEmoji.emojis;
        
        for (NSInteger j = 0; j < typeArray.count; j++) {
            //            STEmoji *tempEmoji = typeArray[j];
            if (j % cellCount == 0) {
                
                if (tempEmojiArray.count) {
                    TMSEmoji *emoji = [TMSEmoji new];
                    emoji.title = originEmoji.title;
                    emoji.emojis = tempEmojiArray.copy;
                    emoji.type = originEmoji.type;
                    [tempDataSource addObject:emoji];
                }
                [tempEmojiArray removeAllObjects];
                
                if (j == typeArray.count - 1) {
                    [tempEmojiArray addObject:typeArray[j]];
                    TMSEmoji *emoji = [TMSEmoji new];
                    emoji.title = originEmoji.title;
                    emoji.emojis = tempEmojiArray.copy;
                    emoji.type = originEmoji.type;
                    [tempDataSource addObject:emoji];
                }
                
            } else if (j == typeArray.count - 1) {
                [tempEmojiArray addObject:typeArray[j]];
                TMSEmoji *emoji = [TMSEmoji new];
                emoji.title = originEmoji.title;
                emoji.emojis = tempEmojiArray.copy;
                emoji.type = originEmoji.type;
                [tempDataSource addObject:emoji];
                
            }
            [tempEmojiArray addObject:typeArray[j]];
        }
    }
    
    return tempDataSource.copy;
}

@end

@implementation TMSCustomEmoji

+ (NSArray<TMSCustomEmoji *> *)allEmojis {
    
    NSMutableArray *emojis = [NSMutableArray array];
    
    int count = arc4random_uniform(31);
    for (NSInteger i = 0; i < 30; i++) {
        TMSCustomEmoji *emoji = [[TMSCustomEmoji alloc] init];
        emoji.pic = [NSString stringWithFormat:@"test_%zd", i % 10];
        [emojis addObject:emoji];
    }
    
    return [emojis copy];
}
@end

