//
//  TMSEmoji.h
//  TMSStickerView
//
//  Created by TMS on 2019/1/15.
//  Copyright © 2019年 TMS. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TMSEmojiType) {
    // emoji show type
    //    STEmojiTypeRecent = 0,
    TMSEmojiTypePeople = 0,
    TMSEmojiTypeFlower,
    TMSEmojiTypeBell,
    TMSEmojiTypeVehicle,
    TMSEmojiTypeNumber,
    TMSEmojiTypeCustom,
};

@interface TMSEmoji : NSObject

@property (assign, nonatomic) TMSEmojiType type;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSArray *emojis;

@end

@interface TMSEmoji (Generate)
+ (NSArray *)allEmojis;
+ (NSArray *)allEmojisWithoutCustomEmoji;
@end

@interface TMSCustomEmoji : NSObject

//@property (nonatomic, copy) NSString *emojiId;
@property (nonatomic, copy) NSString *pic;

+ (NSArray<TMSCustomEmoji *> *)allEmojis;

@end

