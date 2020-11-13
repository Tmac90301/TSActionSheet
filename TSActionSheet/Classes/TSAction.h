//
//  TSAction.h
//  GeneralTests
//
//  Created by 彭志 on 2020/10/21.
//  Copyright © 2020 彭志. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TSActionStyle) {
    TSActionStyleDefault        =   0,
    TSActionStyleCancel,
    TSActionStyleDestructive
};

NS_ASSUME_NONNULL_BEGIN

@interface TSAction : NSObject

@property (nonatomic, assign) TSActionStyle style;      //!< 样式
@property (nonatomic, copy) NSString *title;            //!< 选项标题
@property (nonatomic, strong, nullable) UIImage *icon;  //!< 选项图标
@property (nonatomic, copy) void (^handler)(void);       //!< 点击事件回调

+ (instancetype)actionWithStyle:(TSActionStyle)style title:(NSString *)title handler:(nullable void (^)(void))handler;
+ (instancetype)actionWithStyle:(TSActionStyle)style title:(NSString *)title icon:(nullable UIImage *)icon handler:(void (^)(void))handler;

@end

NS_ASSUME_NONNULL_END
