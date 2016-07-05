//
//  BaseViewController.h
//  WT
//
//  Created by Mac on 16/7/2.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface BaseViewController : UIViewController

-(void)setupSubviews;

-(void)setDefaultLeftBarButtonItem;

-(void)goback;

-(void)showLoading;

-(void)hideLoading;

-(void)showInfomation:(NSString *)info;

-(void)showProgress:(CGFloat)progress;

@end
