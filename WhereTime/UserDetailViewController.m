//
//  UserDetailViewController.m
//  WT
//
//  Created by Mac on 16/7/2.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#import "UserDetailViewController.h"
//#import <SDWebImage/UIImageView+WebCache.h>
#import "UserService.h"
#import <BmobIMSDK/BmobIMSDK.h>
//#import "ChatViewController.h"

@interface UserDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@property (weak, nonatomic) IBOutlet UIButton *addButton;


@end

@implementation UserDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setDefaultLeftBarButtonItem];
    [self setupSubviews];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupSubviews{

    self.nameLabel.text = self.userInfo.name;

}


- (IBAction)addFriend {
    [UserService addFriendNoticeWithUserId:self.userInfo.userId completion:^(BOOL isSuccessful, NSError *error) {
        if (error) {
            [self showInfomation:error.localizedDescription];
        }else{
            [self showInfomation:@"已发送添加好友请求"];
        }
    }];
}



@end
