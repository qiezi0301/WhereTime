//
//  MessageService.m
//  WT
//
//  Created by Mac on 16/7/2.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#import "MessageService.h"

@implementation MessageService

/**
 *  查找某个用户的通知信息
 *
 *  @param date  当前时间
 *  @param block 信息数组
 */
//+(void)inviteMessages:(NSDate *)date completion:(BmobObjectArrayResultBlock)block{
//    
//    BmobQuery *query = [BmobQuery queryWithClassName:kInviteMessageTable];
//    [query whereKey:@"toUser" equalTo:[BmobUser getCurrentUser].mobilePhoneNumber];
//    NSLog(@"[BmobUser getCurrentUser]==%@",[BmobUser getCurrentUser].mobilePhoneNumber);
//    //    [query whereKey:@"type" equalTo:[NSNumber numberWithInteger:SystemMessageContactAdd]];
//    [query includeKey:@"fromUser,toUser"];
//    [query orderByDescending:@"createdAt"];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
//        if (error) {
//            if (block) {
//                block(nil,error);
//            }
//        }else{
//            NSMutableArray *result = [NSMutableArray array];
//            for (BmobObject *obj in array) {
//                SysMessage *msg = [[SysMessage alloc] initFromBmobObject:obj];
//                msg.fromUser = [obj objectForKey:@"fromUser"];
//                msg.toUser = [obj objectForKey:@"toUser"];
//                
//                [result addObject:msg];
//            }
//            if (block) {
//                block(result,nil);
//            }
//        }
//    }];
//}

/**
 *  查找某个用户的通知信息
 *
 *  @param date  当前时间
 *  @param block 信息数组
 */
+(void)inviteMessages:(NSDate *)date completion:(BmobObjectArrayResultBlock)block{
    
    BmobQuery *query = [BmobQuery queryWithClassName:kInviteMessageTable];
    [query whereKey:@"toUser" equalTo:[BmobUser getCurrentUser]];

    [query includeKey:@"fromUser,toUser"];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error) {
            if (block) {
                block(nil,error);
            }
        }else{
            NSMutableArray *result = [NSMutableArray array];
            for (BmobObject *obj in array) {
                SysMessage *msg = [[SysMessage alloc] initFromBmobObject:obj];
                msg.fromUser = [obj objectForKey:@"fromUser"];
                msg.toUser = [obj objectForKey:@"toUser"];
                
                [result addObject:msg];
            }
            if (block) {
                block(result,nil);
            }
        }
    }];
}

@end
