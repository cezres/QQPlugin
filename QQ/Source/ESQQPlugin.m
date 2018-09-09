//
//  ESQQPlugin.m
//  QQDylib
//
//  Created by 晨风 on 2018/5/8.
//  Copyright © 2018年 晨风. All rights reserved.
//

#import "ESQQPlugin.h"
#import <CaptainHook/CaptainHook.h>
#import <UIKit/UIKit.h>
#import <Cycript/Cycript.h>
#import <objc/runtime.h>

#import <mach/mach_time.h>

@implementation ESQQPlugin

+ (void)load {
//    static uint64_t loadTime;
//    static uint64_t applicationRespondedTime = -1;
//    static mach_timebase_info_data_t timebaseInfo;
//    
//    loadTime = mach_absolute_time();
//    mach_timebase_info(&timebaseInfo);
//    
//    @autoreleasepool {
//        __block id obs;
//        obs = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                applicationRespondedTime = mach_absolute_time();
//                uint64_t machTime = applicationRespondedTime - loadTime;
//                double time = ((machTime / 1e9) * timebaseInfo.numer) / timebaseInfo.denom;
//                NSLog(@"StartupMeasurer: it took %f seconds until the app could respond to user interaction.", time);
//            });
//            [[NSNotificationCenter defaultCenter] removeObserver:obs];
//        }];
//    }
}


@end


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"



CHDeclareClass(NSBundle);

CHOptimizedMethod0(self, NSString*, NSBundle, bundleIdentifier) {
    NSString *call = [NSThread callStackSymbols][1];
    if ([call rangeOfString:@"QQ"].length ||
        [call rangeOfString:@"TlibDy"].length) {
        return @"com.tencent.mqq";
    }
    else {
        return CHSuper0(NSBundle, bundleIdentifier);
    }
}

CHOptimizedMethod1(self, id, NSBundle, objectForInfoDictionaryKey, NSString*, key) {
    if ([key isEqualToString:@"CFBundleIdentifier"]) {
        NSString *call = [NSThread callStackSymbols][1];
        if ([call rangeOfString:@"QQ"].length ||
            [call rangeOfString:@"TlibDy"].length) {
            return @"com.tencent.mqq";
        }
        else {
            return  CHSuper1(NSBundle, objectForInfoDictionaryKey, key);
        }
    }
    else {
        return  CHSuper1(NSBundle, objectForInfoDictionaryKey, key);
    }
}

CHConstructor{
    CHLoadLateClass(NSBundle);
    CHClassHook0(NSBundle, bundleIdentifier);
    CHClassHook1(NSBundle, objectForInfoDictionaryKey);
}



CHDeclareClass(INPreferences);
typedef void(^ESINPreferencesBlock)(NSInteger status);

CHOptimizedClassMethod0(self, NSInteger, INPreferences, siriAuthorizationStatus) { return 0; }
CHOptimizedClassMethod1(self, void, INPreferences, requestSiriAuthorization, ESINPreferencesBlock, block) { }

CHConstructor {
    CHLoadLateClass(INPreferences);
    CHClassHook0(INPreferences, siriAuthorizationStatus);
    CHClassHook1(INPreferences, requestSiriAuthorization);
}

#pragma clang diagnostic pop

