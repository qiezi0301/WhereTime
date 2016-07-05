//
//  UserTableViewController.h
//  WhereTime
//
//  Created by 张家亮 on 16/3/10.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BmobSDK/Bmob.h>
#import <BmobIMSDK/BmobIMSDK.h>

#import "BMOBUtil.h"


@interface UserTableViewController : UITableViewController

@property(nonatomic,strong)BMOBUtil *bmobUtil;


@end
