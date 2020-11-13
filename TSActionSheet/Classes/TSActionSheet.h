//
//  TSActionSheet.h
//  GeneralTests
//
//  Created by 彭志 on 2020/10/21.
//  Copyright © 2020 彭志. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSAction.h"

NS_ASSUME_NONNULL_BEGIN

@class TSActionSheetConfig;

@interface TSActionSheet : UIView

@property (nonatomic, strong) TSActionSheetConfig *config;      //!< 样式配置
@property (nonatomic, copy, nullable) NSString *sheetTitle;     //!< 表单标题

+ (instancetype)actionSheet;
+ (instancetype)actionSheetWithConfig:(nullable TSActionSheetConfig *)config;
+ (instancetype)actionSheetWithTitle:(nullable NSString *)title config:(nullable TSActionSheetConfig *)config;

/// 添加弹窗选项
- (void)addAction:(TSAction *)action;

/// 添加多个弹窗选项
- (void)addActions:(NSArray<TSAction *> *)actions;

/// Show in window
- (void)show;
/// Show in designated view, if nil, show in window
- (void)showInView:(nullable UIView *)view;
- (void)dismiss;

@end


@interface TSActionSheetConfig : NSObject

@property (nonatomic, strong) UIFont *sheetTitleFont;           //!< 表单标题文字字体，默认 PingFangSC-Regular 13
@property (nonatomic, strong) UIColor *sheetTitleColor;         //!< 表单标题文字颜色，默认 #999999
@property (nonatomic, strong) UIFont *titleFont;                //!< 选项字体，默认 PingFangSC-Regular 18
@property (nonatomic, strong) UIColor *titleColor;              //!< 默认选项文字颜色，默认 #333333
@property (nonatomic, strong) UIColor *destructiveTitleColor;   //!< 预警选项标题文字颜色，默认 #FF4D4F
@property (nonatomic, strong) UIColor *separatorColor;          //!< 分割线颜色，默认 #E8E8E8
@property (nonatomic, assign) CGFloat backgroundAlpha;          //!< 背景透明度，默认 0.4

+ (instancetype)defaultConfig;

@end

NS_ASSUME_NONNULL_END
