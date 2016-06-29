//
//  MainNavigationController.h
//  WT
//
//  Created by Mac on 16/6/20.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMOBUtil.h"

@interface MainNavigationController : UINavigationController

@property(nonatomic,strong)BMOBUtil *bmobUtil;
+ (instancetype)shareMainNavigationController;
- (void)pushToHomeViewControllerAnimated:(BOOL)animated;
- (void)popToLoginViewControllerAnimated:(BOOL)animated;

@end
