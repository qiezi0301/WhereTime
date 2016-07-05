//
//  BmobIMDemoPCH.h
//  WT
//
//  Created by Mac on 16/7/2.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#ifndef BmobIMDemoPCH_h
#define BmobIMDemoPCH_h

//#import "UIColor+SubClass.h"

typedef NS_ENUM(int,SystemMessageContact){
    SystemMessageContactAdd = 0,
    SystemMessageContactAgree,
    SystemMessageContactRefuse
};

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kInviteMessageTable      @"InviteMessage"
#define kFriendTable             @"Friend"
#define kNewMessagesNotifacation @"NewMessagesNotifacation"
#define kNewMessageFromer        @"NewMessageFromer"

#define kDefaultViewBackgroundColor [UIColor colorWithRed:241 green:242 blue:246 alpha:1]


#endif /* BmobIMDemoPCH_h */
