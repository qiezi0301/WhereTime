//
//  BmobIMUserInfo+BmobUser.h
//  WT
//
//  Created by Mac on 16/7/2.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#import <BmobIMSDK/BmobIMSDK.h>
#import <BmobSDK/Bmob.h>
@interface BmobIMUserInfo (BmobUser)

+(instancetype)userInfoWithBmobUser:(BmobUser *)user;

@end
