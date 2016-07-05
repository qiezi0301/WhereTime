//
//  MessageService.h
//  WT
//
//  Created by Mac on 16/7/2.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BmobIMDemoPCH.h"
#import <BmobSDK/Bmob.h>
#import "SysMessage.h"
#import <BmobIMSDK/BmobIMSDK.h>

typedef void(^uploadBlock)(id resule ,NSError *error);

@interface MessageService : NSObject

/**
 *  查找某个用户的通知信息
 *
 *  @param date  当前时间
 *  @param block 信息数组
 */
+(void)inviteMessages:(NSDate *)date completion:(BmobObjectArrayResultBlock)block;


@end
