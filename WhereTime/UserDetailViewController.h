//
//  UserDetailViewController.h
//  WT
//
//  Created by Mac on 16/7/2.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BmobIMSDK/BmobIMSDK.h>
#import "BaseViewController.h"


@interface UserDetailViewController : BaseViewController

@property (strong, nonatomic) BmobIMUserInfo *userInfo;

@end

