//
//  FriendTableViewController.h
//  WT
//
//  Created by Mac on 16/7/3.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BmobSDK/Bmob.h>
#import <BmobIMSDK/BmobIMSDK.h>
#import "BaseViewController.h"

#import "BMOBUtil.h"

@interface FriendTableViewController : UITableViewController

@property(nonatomic,strong)BMOBUtil *bmobUtil;

@end
