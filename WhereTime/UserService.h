//
//  UserService.h
//  WT
//
//  Created by Mac on 16/7/2.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BmobSDK/Bmob.h>
#import <BmobIMSDK/BmobIMSDK.h>
#import "constant.h"
#import "BmobIMDemoPCH.h"
#import "BmobIMUserInfo+BmobUser.h"
#import "BMOBUtil.h"

@interface UserService : BMOBUtil

/**
 *  加载所有用户信息，除了自己
 *
 *  @param date  当前时间
 *  @param block 用户的数组
 */
+(void)loadUsersWithDate:(NSDate *)date completion:(BmobObjectArrayResultBlock)block;

/**
 *  加载特定用户的信息
 *
 *  @param objectId 用户的objectId
 *  @param block    回调
 */
+(void)loadUserWithUserId:(NSString *)objectId
               completion:(void(^)(BmobIMUserInfo *result ,NSError *error))block;

+(void)loadUsersWithDate:(NSDate *)date
                 keyword:(NSString *)keyword
              completion:(BmobObjectArrayResultBlock)block;


/**
 *  添加好友
 *
 *  @param userId 用户的objectId
 *  @param block  回调的结果
 */
+(void)addFriendNoticeWithUserId:(NSString *)userId completion:(BmobBooleanResultBlock)block;

/**
 *  同意添加好友
 *
 *  @param objectId 消息的objectid
 *  @param userId   对象
 *  @param block    回调的结果
 */
+(void)agreeFriendWithObejctId:(NSString *)objectId userId:(NSString*)userId completion:(BmobBooleanResultBlock)block;

/**
 *  拒绝添加好友
 *
 *  @param objectId 消息的objectId
 *  @param block    回调的结果
 */
+(void)refuseFriendWithObejctId:(NSString *)objectId completion:(BmobBooleanResultBlock)block;

/**
 *  同意后互为好友
 *
 *  @param user       用户
 *  @param friendUser 好友
 *  @param block      <#block description#>
 */
+(void)addFriendWithUser:(BmobUser *)user
                  friend:(BmobUser *)friendUser
              completion:(BmobBooleanResultBlock)block;

/**
 *  某人的好友数组
 *
 *  @param block 好友
 */
+(void)friendsWithCompletion:(BmobObjectArrayResultBlock)block;


+(void)loadUsersWithUserIds:(NSArray *)array completion:(BmobObjectArrayResultBlock)block;


@end
