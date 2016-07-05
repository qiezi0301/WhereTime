//
//  SysMessage.h
//  WT
//
//  Created by Mac on 16/7/2.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BmobSDK/Bmob.h>
@interface SysMessage : BmobObject

@property (strong, nonatomic) BmobUser *fromUser;
@property (strong, nonatomic) BmobUser *toUser;
@property (strong, nonatomic) NSNumber *type;

@end

