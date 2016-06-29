//
//  MainNavigationController.m
//  WT
//
//  Created by Mac on 16/6/20.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#import "MainNavigationController.h"

@implementation MainNavigationController

+ (instancetype)shareMainNavigationController
{
    return (MainNavigationController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bmobUtil = [BMOBUtil getInstance];
    
    //判断是否登录
    WTUserModel *u = [self.bmobUtil getUser];
    NSLog(@"获取用户信息==%@",u.phoneNumber);
    
    if (u!=nil) {
        [self pushToHomeViewControllerAnimated:YES];
    }else{
        [self popToLoginViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)pushToHomeViewControllerAnimated:(BOOL)animated
{
    
    NSLog(@"登录成功,跳转到首页");
    UIStoryboard *HomeStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIViewController *viewController = [HomeStoryBoard instantiateViewControllerWithIdentifier:@"PhotoViewController"];
    [self setViewControllers:[NSArray arrayWithObject:viewController] animated:YES];
    
}

- (void)popToLoginViewControllerAnimated:(BOOL)animated{
    
    NSLog(@"跳转到登录页面");
    UIStoryboard *loginStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIViewController *viewController = [loginStoryBoard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self setViewControllers:[NSArray arrayWithObject:viewController] animated:YES];
    
}


@end
