//
//  TSActionSheet.m
//  GeneralTests
//
//  Created by 彭志 on 2020/10/21.
//  Copyright © 2020 彭志. All rights reserved.
//

#import "TSActionSheet.h"
#import "UIApplication+TSKeyWindow.h"

#pragma mark - 弹窗选项

/** 弹窗选项视图 */
@interface TSActionItem : UIView

@property (nonatomic, strong) TSAction *action;
@property (nonatomic, copy) void (^tapCallBack)(void);

@property (nonatomic, assign) CGSize titleSize;
@property (nonatomic, assign) CGSize iconSize;

@property (nonatomic, weak) UIImageView *iconView;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UIView *separator;

+ (instancetype)actionItemWithAction:(TSAction *)action titleColor:(UIColor *)titleColor separatorColor:(UIColor *)separatorColor font:(UIFont *)font;

@end

@implementation TSActionItem

+ (instancetype)actionItemWithAction:(TSAction *)action titleColor:(UIColor *)titleColor separatorColor:(UIColor *)separatorColor font:(UIFont *)font {
    return [[self alloc] initWithAction:action titleColor:titleColor separatorColor:(UIColor *)separatorColor font:font];
}

- (instancetype)initWithAction:(TSAction *)action titleColor:(UIColor *)titleColor separatorColor:(UIColor *)separatorColor font:(UIFont *)font {
    if (self = [super initWithFrame:CGRectZero]) {
        _action = action;
        _titleSize = [action.title boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil].size;
        _iconSize = CGSizeMake(18, ceil(_titleSize.height));
        
        if (action.icon) {
            UIImageView *iconView = [[UIImageView alloc] initWithImage:action.icon];
            iconView.contentMode = UIViewContentModeScaleAspectFit;
            [self addSubview:iconView];
            _iconView = iconView;
        }
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textColor = titleColor;
        titleLabel.font = font;
        titleLabel.text = action.title;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        _titleLabel = titleLabel;
        
        UIView *separator = [[UIView alloc] init];
        separator.backgroundColor = separatorColor;
        [self addSubview:separator];
        _separator = separator;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemDidTap:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds), height = CGRectGetHeight(self.bounds), elementPadding = 7;
    CGFloat origin = (width - (self.iconView ? (elementPadding + self.iconSize.width) : 0) - self.titleSize.width) * 0.5;
    CGFloat top = (height - self.titleSize.height) * 0.5;
    
    self.iconView.frame = CGRectMake(origin, top, self.iconSize.width, self.iconSize.height);
    self.titleLabel.frame = CGRectMake(self.iconView ? CGRectGetMaxX(self.iconView.frame) + elementPadding : origin, top, self.titleSize.width, self.titleSize.height);
    self.separator.frame = CGRectMake(0, height - 0.5, width, 0.5);
}

- (void)itemDidTap:(UITapGestureRecognizer *)tap {
    !self.action.handler ?: self.action.handler();
    !self.tapCallBack ?: self.tapCallBack();
}

@end


#pragma mark - 弹窗实现

@interface TSActionSheet ()

@property (nonatomic, strong) UIButton *bgMaskBtn;
@property (nonatomic, assign) CGFloat contentHeight;

@property (nonatomic, strong) TSAction *cancelAction;
@property (nonatomic, assign) BOOL alreadyLayout;   //!< 是否已经计算好布局

@property (nonatomic, strong) NSMutableArray<TSAction *> *actions;

@end

@implementation TSActionSheet

+ (instancetype)actionSheet {
    return [self actionSheetWithConfig:nil];
}

+ (instancetype)actionSheetWithConfig:(nullable TSActionSheetConfig *)config {
    return [self actionSheetWithTitle:nil config:nil];
}

+ (instancetype)actionSheetWithTitle:(NSString *)title config:(TSActionSheetConfig *)config {
    TSActionSheet *actionSheet = [[self alloc] init];
    actionSheet.sheetTitle = title;
    actionSheet.config = config;
    return actionSheet;
}

- (void)addAction:(TSAction *)action {
    if (action.style != TSActionStyleCancel) {
        [self.actions addObject:action];
    } else if (action.style == TSActionStyleCancel) {
        self.cancelAction = action;
    }
}

- (void)addActions:(NSArray<TSAction *> *)actions {
    for (TSAction *action in actions) {
        [self addAction:action];
    }
}

- (void)layoutActionItems {
    self.backgroundColor = [UIColor whiteColor];
    self.config = self.config ?: [TSActionSheetConfig defaultConfig];
    
    CGFloat titleHeight = 0;
    // 如果有弹窗标题
    if (self.sheetTitle.length > 0) {
        CGFloat sidePadding = 50, topPadding = 16;
        UIFont *sheetTitleFont = self.config.sheetTitleFont;
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle defaultParagraphStyle].mutableCopy;
        paragraphStyle.maximumLineHeight = paragraphStyle.minimumLineHeight = ceil(sheetTitleFont.lineHeight);
        paragraphStyle.alignment = NSTextAlignmentCenter;
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:self.sheetTitle attributes:@{NSFontAttributeName : sheetTitleFont, NSForegroundColorAttributeName : self.config.sheetTitleColor, NSParagraphStyleAttributeName : paragraphStyle}];
        CGFloat maxWidth = CGRectGetWidth([UIScreen mainScreen].bounds) - sidePadding * 2;
        CGSize titleSize = [attributedTitle boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.numberOfLines = 0;
        titleLabel.attributedText = attributedTitle;
        titleLabel.frame = CGRectMake(sidePadding, topPadding, maxWidth, titleSize.height);
        [self addSubview:titleLabel];
        titleHeight = topPadding * 2 + titleSize.height;
        
        UIView *separator = [[UIView alloc] init];
        separator.backgroundColor = self.config.separatorColor;
        [self addSubview:separator];
        separator.frame = CGRectMake(0, titleHeight - 0.5, CGRectGetWidth([UIScreen mainScreen].bounds), 0.5);
    }
    
    CGFloat itemHeight = 56, itemWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    for (NSInteger i = 0; i < self.actions.count; i++) {
        TSAction *action = self.actions[i];
        UIColor *titleColor = action.style == TSActionStyleDestructive ? self.config.destructiveTitleColor : self.config.titleColor;
        TSActionItem *actionItem = [TSActionItem actionItemWithAction:action titleColor:titleColor separatorColor:self.config.separatorColor font:self.config.titleFont];
        __weak typeof(self) weakSelf = self;
        actionItem.tapCallBack = ^{
            [weakSelf dismiss];
        };
        actionItem.frame = CGRectMake(0, titleHeight + itemHeight * i, itemWidth, itemHeight);
        [self addSubview:actionItem];
    }
    
    UIView *paddingView = [[UIView alloc] init];
    paddingView.backgroundColor = [UIColor colorWithWhite:244 / 255.0 alpha:1];
    paddingView.frame = CGRectMake(0, titleHeight + self.actions.count * itemHeight, itemWidth, 6);
    [self addSubview:paddingView];
    
    if (self.cancelAction == nil) {
        self.cancelAction = [TSAction actionWithStyle:TSActionStyleCancel title:@"Cancel" handler:nil];
    }
    
    TSActionItem *cancel = [TSActionItem actionItemWithAction:self.cancelAction titleColor:self.config.titleColor separatorColor:self.config.separatorColor font:self.config.titleFont];
    __weak typeof(self) weakSelf = self;
    cancel.tapCallBack = ^{
        [weakSelf dismiss];
    };
    cancel.frame = CGRectMake(0, CGRectGetMaxY(paddingView.frame), itemWidth, itemHeight);
    [self addSubview:cancel];
    
    self.contentHeight = CGRectGetMaxY(cancel.frame);
}

#pragma mark - Show & Dismiss

- (void)show {
    [self showInView:nil];
}

- (void)showInView:(UIView *)view {
    if (self.actions.count == 0) {
        return;
    }
    
    [self layoutActionItems];
    
    view = view ? : [UIApplication sharedApplication].ts_keyWindow;
    self.bgMaskBtn.frame = view.bounds;
    self.frame = CGRectMake(0, CGRectGetHeight(view.bounds), CGRectGetWidth(view.bounds), self.contentHeight);
    [view addSubview:self.bgMaskBtn];
    [view addSubview:self];
    self.bgMaskBtn.alpha = 0;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.bgMaskBtn.alpha = 1;
        self.transform = CGAffineTransformMakeTranslation(0, -self.contentHeight);
    } completion:nil];
}

- (void)dismiss {
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.transform = CGAffineTransformIdentity;
        self.bgMaskBtn.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self.bgMaskBtn removeFromSuperview];
    }];
}

#pragma mark - Lazy loads

- (UIButton *)bgMaskBtn {
    if (!_bgMaskBtn) {
        _bgMaskBtn = [[UIButton alloc] init];
        _bgMaskBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:self.config.backgroundAlpha];
        [_bgMaskBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bgMaskBtn;
}

- (NSMutableArray<TSAction *> *)actions {
    if (!_actions) {
        _actions = [NSMutableArray array];
    }
    return _actions;
}

@end


#pragma mark - 弹窗配置

@implementation TSActionSheetConfig

+ (instancetype)defaultConfig {
    TSActionSheetConfig *config = [[self alloc] init];
    config.sheetTitleFont = [UIFont fontWithName:@"PingFangSC-Regular" size:13];
    config.sheetTitleColor = [UIColor colorWithWhite:153 / 255.0 alpha:1];
    config.titleFont = [UIFont fontWithName:@"PingFangSC-Regular" size:18];
    config.titleColor = [UIColor colorWithWhite:51 / 255.0 alpha:1];
    config.destructiveTitleColor = [UIColor colorWithRed:255 / 255.0 green:77 / 255.0 blue:79 / 255.0 alpha:1];
    config.separatorColor = [UIColor colorWithWhite:232 / 255.0 alpha:1];
    config.backgroundAlpha = 0.4;
    return config;
}

@end
