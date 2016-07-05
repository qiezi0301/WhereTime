//
//  BaseViewController.m
//  WT
//
//  Created by Mac on 16/7/2.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController()

@property (strong, nonatomic) MBProgressHUD *hud;

@end

@implementation BaseViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    //    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.backBarButtonItem.title = @"为什么这里为空";
    
    if (self.navigationController.view) {
        _hud = [[MBProgressHUD alloc]initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:self.hud];
    }else{
        _hud = [[MBProgressHUD alloc]initWithView:self.view];
        [self.view  addSubview:self.hud];
    }
    
}

-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

-(void)setupSubviews{
    
}

-(void)setDefaultLeftBarButtonItem{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 44, 44);
    [button setImage:[UIImage imageNamed:@"common_back"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"common_back_"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(goback) forControlEvents:UIControlEventTouchUpInside];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0,  -10, 0,10)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem.title = @"";
}

-(void)goback{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)showLoading{
    self.hud.mode = MBProgressHUDModeIndeterminate;
    [self.hud show:YES];
}

-(void)hideLoading{
    [self.hud hide:YES afterDelay:0.5f];
}

-(void)showInfomation:(NSString *)info{
    self.hud.mode = MBProgressHUDModeText;
    self.hud.detailsLabelText = info;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:0.5f];
    
}

-(void)showProgress:(CGFloat)progress{
    self.hud.progress = progress;
    self.hud.mode = MBProgressHUDModeAnnularDeterminate;
}

@end
