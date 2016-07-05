//
//  BmobIMUserInfo+BmobUser.m
//  WT
//
//  Created by Mac on 16/7/2.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#import "BmobIMUserInfo+BmobUser.h"

@implementation BmobIMUserInfo (BmobUser)
+(instancetype)userInfoWithBmobUser:(BmobUser *)user{
    BmobIMUserInfo *info  = [[BmobIMUserInfo alloc] init];
    info.userId = user.objectId;
    info.name = user.username;
//    info.avatar = [user objectForKey:@"avatar"];
    return info;
}
@end
