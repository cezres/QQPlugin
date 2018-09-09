//
//  ESQQRedEnvelope.m
//  QQDylib
//
//  Created by 晨风 on 2018/5/9.
//  Copyright © 2018年 晨风. All rights reserved.
//

#import "ESQQRedEnvelope.h"
#import <CaptainHook/CaptainHook.h>
#import <UIKit/UIKit.h>
#import <Cycript/Cycript.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import "ANYMethodLog.h"

#import "ESQQPluginSettingWindow.h"


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"


typedef void (^CDUnknownBlockType)(void); // return type and parameters are unknown


@interface ESQQRedEnvelope ()

@property (nonatomic, strong) NSMutableSet *openRedEnvelopes;

@end

@implementation ESQQRedEnvelope

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
        _openRedEnvelopes = [NSMutableSet set];
        _openRedEnvelopeDelay = [[NSUserDefaults standardUserDefaults] integerForKey:NSStringFromSelector(@selector(openRedEnvelopeDelay))];
        _autoOpenRedEnvelopeEnable = [[NSUserDefaults standardUserDefaults] boolForKey:NSStringFromSelector(@selector(autoOpenRedEnvelopeEnable))];
    }
    return self;
}

- (void)setOpenRedEnvelopeDelay:(NSInteger)openRedEnvelopeDelay {
    _openRedEnvelopeDelay = openRedEnvelopeDelay;
    [[NSUserDefaults standardUserDefaults] setInteger:openRedEnvelopeDelay forKey:NSStringFromSelector(@selector(openRedEnvelopeDelay))];
}

- (void)setAutoOpenRedEnvelopeEnable:(BOOL)autoOpenRedEnvelopeEnable {
    _autoOpenRedEnvelopeEnable = autoOpenRedEnvelopeEnable;
    [[NSUserDefaults standardUserDefaults] setBool:_autoOpenRedEnvelopeEnable forKey:NSStringFromSelector(@selector(autoOpenRedEnvelopeEnable))];
}

- (void)openRedEnvelopeWithMessageModel:(id)model {
    // model -> QQMessageModel
    NSString *content = [model valueForKey:@"content"];
    if (!content || ![content isKindOfClass:[NSString class]] || ![content hasPrefix:@"{\"icon\""]) {
        return;
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithBytes:content.UTF8String length:[content lengthOfBytesUsingEncoding:NSUTF8StringEncoding]] options:kNilOptions error:nil];
    if (!dict || ![[dict objectForKey:@"content"] isEqualToString:@"QQ红包"]) {
        return;
    }
    
    unsigned long long time = [[model valueForKey:@"time"] unsignedLongLongValue];
    if ([NSDate date].timeIntervalSince1970 - time > 60 * 1) {
        return;
    }
    
    
    NSString *senduin = [model valueForKey:@"uin"];
    if ([senduin isEqualToString:[self curUin]]) {
        if (![model isKindOfClass:NSClassFromString(@"QQRecentMessageModel")]) {
            return;
        }
    }
    
    
    long long msgUid = [[model valueForKey:@"msgUid"] longLongValue] + time;
    if ([self.openRedEnvelopes containsObject:@(msgUid)]) {
        return;
    }
    [self.openRedEnvelopes addObject:@(msgUid)];
    
    
    NSString *authkey = [dict objectForKey:@"authkey"];
    NSInteger channel = [[dict objectForKey:@"redChannel"] integerValue];
    NSString *listid = [dict objectForKey:@"billno"];
    NSNumber *skinid = [dict objectForKey:@"skinId"];
    
    NSInteger groupid = [[model valueForKey:@"groupCode"] integerValue];
    NSInteger grouptype = 1;
    NSString *sendernickname = [model valueForKey:@"nickname"];
    NSString *senderuin = [model valueForKey:@"uin"];
    
    NSMutableDictionary *extra_data = [NSMutableDictionary dictionary];
    [extra_data setObject:@"" forKey:@"answer"];
    [extra_data setObject:authkey forKey:@"authkey"];
    [extra_data setObject:@(channel) forKey:@"channel"];
    [extra_data setObject:@{@"channel": @(channel)} forKey:@"detailinfo"];
    [extra_data setObject:listid forKey:@"listid"];
    [extra_data setObject:[self nickname] forKey:@"name"];
    [extra_data setObject:@(-1) forKey:@"pop_personAnimation"];
    [extra_data setObject:[self skey] forKey:@"skey"];
    [extra_data setObject:[self skey_type] forKey:@"skey_type"];
    [extra_data setObject:skinid forKey:@"skinid"];
    
    
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:[self app_info] forKey:@"app_info"];
    [param setObject:@(2) forKey:@"come_from"];
    [param setObject:extra_data forKey:@"extra_data"];
    [param setObject:@(groupid) forKey:@"groupid"];
    [param setObject:@(grouptype) forKey:@"grouptype"];
    [param setObject:@0 forKey:@"resource_type"];
    [param setObject:sendernickname forKey:@"sendernickname"];
    [param setObject:senderuin forKey:@"senderuin"];
    [param setObject:[self curUin] forKey:@"userId"];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC + self.openRedEnvelopeDelay * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            UINavigationController *controller = [UINavigationController new];
            id wallet = ((id (*)(Class, SEL))objc_msgSend)(NSClassFromString(@"QQWallet"), @selector(GetInstance));
            ((void (*)(id, SEL, id, id, id, CDUnknownBlockType))objc_msgSend)(wallet, @selector(gotoTenpayView:rootVC:params:completion:), @"graphb", controller, param, nil);

        });
    });
}


- (NSString *)nickname {
    id instance = ((id (*)(Class, SEL))objc_msgSend)(NSClassFromString(@"QAccountService"), @selector(getInstance));
    return ((NSString* (*)(id, SEL))objc_msgSend)(instance, @selector(getLoginNickname));
}
- (NSString *)app_info {
    NSString *app_info = [[NSUserDefaults standardUserDefaults] stringForKey:@"ESQQRedEnvelope_app_info"];
    if (app_info) {
        return app_info;
    }
    id instance = ((id (*)(Class, SEL))objc_msgSend)(NSClassFromString(@"CFT_TenpayOrderInfo"), @selector(getVerifyPswInstance));
    app_info = ((NSString* (*)(id, SEL))objc_msgSend)(instance, @selector(app_info));
    if (app_info) {
        NSRange range = [app_info rangeOfString:@"#" options:NSBackwardsSearch];
        if (range.length) {
            [app_info stringByReplacingCharactersInRange:NSMakeRange(range.location+range.length, app_info.length - range.location-range.length) withString:@"msg"];
        }
        else {
            app_info = nil;
        }
    }
    
    if (app_info) {
        [[NSUserDefaults standardUserDefaults] setObject:app_info forKey:@"ESQQRedEnvelope_app_info"];
        return app_info;
    }
    else {
        return @"appid#1344242394|bargainor_id#1000030201|channel#msg";
    }
}

- (NSString *)curUin {
    return ((id (*)(Class, SEL))objc_msgSend)(NSClassFromString(@"CFT_PayCenterBusi"), @selector(curUin));
}
- (NSString *)skey {
    NSString *skey = ((id (*)(Class, SEL))objc_msgSend)(NSClassFromString(@"CFT_PayCenterBusi"), @selector(getQQSkey));
    return skey;
}
- (NSNumber *)skey_type {
    NSNumber *skey_type = ((NSNumber* (*)(Class, SEL))objc_msgSend)(NSClassFromString(@"CFT_PayCenterBusi"), @selector(getQQSkeyType));
    return skey_type;
}

@end

CHDeclareClass(QPacketDispatchService);

CHOptimizedMethod4(self, void, QPacketDispatchService, OnMSFRecvDataFromBackend, id, arg1, buf, id, arg2, bufLen, id, arg3, seq, id, arg4) {
    
}

CHConstructor {
    
}



CHDeclareClass(QQMessageModel);

CHOptimizedMethod1(self, id, QQMessageModel, initWithMessageModel, id, arg1) {
    id result = CHSuper1(QQMessageModel, initWithMessageModel, arg1);
    
    NSString *content = [result valueForKey:@"content"];
    if ([content isKindOfClass:[NSString class]] &&
        [content isEqualToString:@"对方撤回了一条消息"]) {
//        return nil;
        [result setValue:@"对方撤回了一条消息___" forKey:@"content"];
    }
    
    if ([ESQQRedEnvelope shareInstance].autoOpenRedEnvelopeEnable) {
        [[ESQQRedEnvelope shareInstance] openRedEnvelopeWithMessageModel:result];
    }
    
    return result;
}

CHDeclareClass(QQWallet);

CHOptimizedMethod4(self, void, QQWallet, gotoTenpayView, id, arg1, rootVC, id, arg2, params, id, arg3, completion, CDUnknownBlockType, arg4) {
    if ([arg1 isEqualToString:@"makeHongbao"]) {
        CHSuper4(QQWallet, gotoTenpayView, arg1, rootVC, arg2, params, arg3, completion, arg4);
    }
    else if ([arg1 isEqualToString:@"graphb"]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:arg3];
        [dict setObject:@"appid#2344242394|bargainor_id#2000030201|channel#msg" forKey:@"app_info"];
        arg3 = dict;
        CHSuper4(QQWallet, gotoTenpayView, arg1, rootVC, arg2, params, arg3, completion, arg4);
    }
}


CHDeclareClass(APMidasPaySignReq);

CHOptimizedMethod0(self, id, APMidasPaySignReq, init) {
    id result = CHSuper0(APMidasPaySignReq, init);
    
    return result;
}

CHDeclareClass(NSMutableDictionary);

CHOptimizedMethod2(self, void, NSMutableDictionary, setObject, id, arg1, forKey, id, arg2) {
    if ([arg2 isEqualToString:@"app_info"]) {
        CHSuper2(NSMutableDictionary, setObject, arg1, forKey, arg2);
    }
    else {
        CHSuper2(NSMutableDictionary, setObject, arg1, forKey, arg2);
    }
}

CHConstructor  {
    @autoreleasepool {
        CHLoadLateClass(QQMessageModel);
        CHClassHook1(QQMessageModel, initWithMessageModel);
        
        CHLoadLateClass(QQWallet);
        CHClassHook4(QQWallet, gotoTenpayView, rootVC, params, completion);
        
        CHLoadLateClass(APMidasPaySignReq);
        CHClassHook0(APMidasPaySignReq, init);
        
        
        CHLoadLateClass(NSMutableDictionary);
        CHClassHook2(NSMutableDictionary, setObject, forKey);
        
//        [param setObject:[self curUin] forKey:@"userId"];
        
//        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//        [dict setObject:@"" forKey:@"app_info"];
//        [dict setValue:@"" forKey:@"app_info"];
        
        /// [[QAccountService getInstance] getLoginNickname]
        /// [[CFT_TenpayOrderInfo getVerifyPswInstance] app_info]
        /// [CFT_PayCenterBusi curUin]
        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            Class cls = NSClassFromString(@"CFT_PayCenterBusi");
//            id dataProvider = ((id (*)(Class, SEL))objc_msgSend)(cls, @selector(nickname));
//            dataProvider = ((id (*)(Class, SEL))objc_msgSend)(cls, @selector(getQQSkey));
//            dataProvider = ((id (*)(Class, SEL))objc_msgSend)(cls, @selector(getQQSkeyType));
//            NSLog(@"%@", dataProvider);
            
//            id dataProvider = ((id (*)(Class, SEL))objc_msgSend)(NSClassFromString(@"QQWallet"), @selector(GetInstance));
//            dataProvider = ((id (*)(Class, SEL))objc_msgSend)(NSClassFromString(@"CFT_TenpayOrderInfo"), @selector(getPayInstance));
//            dataProvider = ((id (*)(Class, SEL))objc_msgSend)(NSClassFromString(@"CFT_TenpayOrderInfo"), @selector(getWalletInstance));
//            NSLog(@"%@", dataProvider);
            
//        });
    }
}


#pragma clang diagnostic pop


//CHDeclareClass(CFT_FF23927);

//CHOptimizedMethod0(self, id, CFT_FF23927, init) {
//    id result = CHSuper0(CFT_FF23927, init);
//    return result;
//}
//
//CHOptimizedMethod1(self, void, CFT_FF23927, setTempVC, id, arg1) {
//    CHSuper1(CFT_FF23927, setTempVC, arg1);
//}
//
//CHOptimizedMethod1(self, void, CFT_FF23927, grapRedDeal, id, arg1) {
//    CHSuper1(CFT_FF23927, grapRedDeal, arg1);
//}
//
//CHOptimizedMethod0(self, void, CFT_FF23927, qpay_hb_na_grap) {
//    CHSuper0(CFT_FF23927, qpay_hb_na_grap);
//}
//
//CHOptimizedMethod0(self, void, CFT_FF23927, requestData) {
//    CHSuper0(CFT_FF23927, requestData);
//}

//requestData

CHConstructor {
    
//    CHLoadLateClass(CFT_FF23927);
//    CHClassHook0(CFT_FF23927, init);
//    CHClassHook1(CFT_FF23927, setTempVC);
//    CHClassHook1(CFT_FF23927, grapRedDeal);
//    CHClassHook0(CFT_FF23927, qpay_hb_na_grap);
//    CHClassHook0(CFT_FF23927, requestData);
    
    
//    [ANYMethodLog logMethodWithClass:NSClassFromString(@"CFT_FF23927") condition:^BOOL(SEL sel) {
//        //
//        return YES;
//    } before:^(id target, SEL sel, NSArray *args, int deep) {
//        //
//        NSLog(@"LOG-- CFT_FF23927 -- %@", NSStringFromSelector(sel));
//    } after:^(id target, SEL sel, NSArray *args, NSTimeInterval interval, int deep, id retValue) {
//        //
//
//    }];
//
//
//    [ANYMethodLog logMethodWithClass:NSClassFromString(@"QQWallet") condition:^BOOL(SEL sel) {
//        //
//        return YES;
//    } before:^(id target, SEL sel, NSArray *args, int deep) {
//        //
//        NSLog(@"LOG-- QQWallet -- %@", NSStringFromSelector(sel));
//    } after:^(id target, SEL sel, NSArray *args, NSTimeInterval interval, int deep, id retValue) {
//        //
//    }];
    
}
