//
//  TSAction.m
//  GeneralTests
//
//  Created by 彭志 on 2020/10/21.
//  Copyright © 2020 彭志. All rights reserved.
//

#import "TSAction.h"

@implementation TSAction

+ (instancetype)actionWithStyle:(TSActionStyle)style title:(NSString *)title handler:(void (^)(void))handler {
    return [self actionWithStyle:style title:title icon:nil handler:handler];
}

+ (instancetype)actionWithStyle:(TSActionStyle)style title:(NSString *)title icon:(nullable UIImage *)icon handler:(void (^)(void))handler {
    TSAction *instance = [[self alloc] init];
    instance.title = title;
    instance.icon = icon;
    instance.handler = handler;
    instance.style = style;
    return instance;
}

@end
