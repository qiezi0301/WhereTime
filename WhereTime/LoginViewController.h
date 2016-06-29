//
//  LoginViewController.h
//  WhereTime
//
//  Created by 张家亮 on 16/3/10.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SMS_SDK/SMSSDK.h>
#import "BMOBUtil.h"
//#import "DBUtil.h"

@interface LoginViewController : UIViewController<BMOBUtilDelegate>

@property(nonatomic,strong)BMOBUtil *bmobUtil;
//@property(nonatomic,strong)DBUtil *util;

@end
