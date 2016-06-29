//
//  WTUserModel.h
//  WhereTime
//
//  Created by 张家亮 on 16/3/19.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BmobSDK/Bmob.h>

@interface WTUserModel : BmobObject

@property(nonatomic,copy)NSString *userName;
@property(nonatomic,copy)NSString *password;
@property(nonatomic,copy)NSString *phoneNumber;


@end
