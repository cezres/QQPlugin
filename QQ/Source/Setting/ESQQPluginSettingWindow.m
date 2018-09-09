//
//  ESQQPluginSettingWindow.m
//  QQDylib
//
//  Created by 晨风 on 2018/5/10.
//  Copyright © 2018年 晨风. All rights reserved.
//

#import "ESQQPluginSettingWindow.h"
#import "ESQQPluginSettingViewController.h"
#import <CaptainHook/CaptainHook.h>
#import <Cycript/Cycript.h>
#import <objc/runtime.h>

#define kSettingWindowSize (44.0f)
#define kSettingWindowMargin (30.0f)

#define kSettingWindowPointXKey @"kSettingWindowPointXKey"
#define kSettingWindowPointYKey @"kSettingWindowPointYKey"

@interface ESQQPluginSettingWindow ()

@property (nonatomic, assign) CGPoint currentPoint;

@end


@implementation ESQQPluginSettingWindow

+ (instancetype)shareInstance {
    static id obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[self alloc] init];
    });
    return obj;
}

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor orangeColor];
        self.windowLevel = UIWindowLevelStatusBar;
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [tap requireGestureRecognizerToFail:pan];
        [self addGestureRecognizer:pan];
        [self addGestureRecognizer:tap];
        
        [self readPoint];
    }
    return self;
}

#pragma mark Action

- (void)tapAction {
    
    ESQQPluginSettingViewController *controller = [ESQQPluginSettingViewController new];
    [controller setDismissComplectionBlock:^{
        self.hidden = NO;
    }];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    self.hidden = YES;
    [[UIApplication sharedApplication].windows.firstObject.rootViewController presentViewController:navigationController animated:YES completion:^{
        
    }];
    
}

- (void)panAction:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:self];
    
    CGPoint targetPoint = CGPointMake(self.frame.origin.x + translation.x, self.frame.origin.y + translation.y);
    if (targetPoint.x < kSettingWindowMargin) {
        targetPoint.x = kSettingWindowMargin;
    } 
    else if (targetPoint.x > [UIScreen mainScreen].bounds.size.width - kSettingWindowMargin - kSettingWindowSize) {
        targetPoint.x = [UIScreen mainScreen].bounds.size.width - kSettingWindowMargin - kSettingWindowSize;
    }
    
    if (targetPoint.y < kSettingWindowMargin) {
        targetPoint.y = kSettingWindowMargin;
    }
    else if (targetPoint.y > [UIScreen mainScreen].bounds.size.height - kSettingWindowMargin - kSettingWindowSize) {
        targetPoint.y = [UIScreen mainScreen].bounds.size.height - kSettingWindowMargin - kSettingWindowSize;
    }
    
    self.frame = CGRectMake(targetPoint.x, targetPoint.y, self.frame.size.width, self.frame.size.height);
    [pan setTranslation:CGPointZero inView:self];
    
    
    if (pan.state != UIGestureRecognizerStateBegan &&
        pan.state != UIGestureRecognizerStateChanged) {
        [self savePoint];
    }
}

- (void)setCurrentPoint:(CGPoint)currentPoint {
    self.frame = CGRectMake(currentPoint.x, currentPoint.y, self.frame.size.width, self.frame.size.height);
}

- (void)savePoint {
    [[NSUserDefaults standardUserDefaults] setDouble:self.frame.origin.x forKey:kSettingWindowPointXKey];
    [[NSUserDefaults standardUserDefaults] setDouble:self.frame.origin.y forKey:kSettingWindowPointYKey];
}

- (void)readPoint {
    CGFloat x,y;
    x = [[NSUserDefaults standardUserDefaults] doubleForKey:kSettingWindowPointXKey];
    y = [[NSUserDefaults standardUserDefaults] doubleForKey:kSettingWindowPointYKey];
    self.frame = CGRectMake(MAX(kSettingWindowMargin, x), MAX(kSettingWindowMargin, y), kSettingWindowSize, kSettingWindowSize);
}

@end



//QQRecentController


//CHDeclareClass(QQRecentController);
//
//CHOptimizedMethod0(self, void, QQRecentController, viewDidLoad) {
//    CHSuper0(QQRecentController, viewDidLoad);
//    
//    [[ESQQPluginSettingWindow shareInstance] makeKeyAndVisible];
//    
//}
//
//CHConstructor  {
//    @autoreleasepool {
//        CHLoadLateClass(QQRecentController);
//        CHClassHook0(QQRecentController, viewDidLoad);
//    }
//}


