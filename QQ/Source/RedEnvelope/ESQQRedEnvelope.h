//
//  ESQQRedEnvelope.h
//  QQDylib
//
//  Created by 晨风 on 2018/5/9.
//  Copyright © 2018年 晨风. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESQQRedEnvelope : NSObject

@property (nonatomic, assign) BOOL autoOpenRedEnvelopeEnable;
@property (nonatomic, assign) NSInteger openRedEnvelopeDelay;

+ (instancetype)shareInstance;

@end
