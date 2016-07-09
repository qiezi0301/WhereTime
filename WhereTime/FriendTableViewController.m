//
//  FriendTableViewController.m
//  WT
//
//  Created by Mac on 16/7/3.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#import "FriendTableViewController.h"
#import "UserService.h"
#import "UserInfoTableViewCell.h"


@interface FriendTableViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableArray *userArray;
@end


static NSString *cellId = @"UserInfoCellID";
@implementation FriendTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _userArray = [[NSMutableArray alloc] init];
    [self loadUsers];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -加载好友
-(void)loadUsers{

    [UserService loadUsersWithDate:[NSDate date] completion:^(NSArray *array, NSError *error) {
        NSLog(@"开始加载用户表中用户%lu",(unsigned long)array.count);

        if (error) {
//            [self showInfomation:error.localizedDescription];
        }else{
            if (array && array.count > 0) {
                [self.userArray setArray:array];
                [self.tableView reloadData];
            }
//            [self hideLoading];
        }
    }];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
      NSLog(@" self.userArray.count===%lu",(unsigned long) self.userArray.count);
    return self.userArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UserInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if(cell == nil) {
        cell = [[UserInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    BmobIMUserInfo *info = self.userArray[indexPath.row];
    [cell setInfo:info];
    
    return cell;
}

#pragma mark - 单元格点击方法

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    BmobIMUserInfo *info = self.userArray[indexPath.row];

    UIAlertController *alertName = [UIAlertController alertControllerWithTitle:@"添加好友" message:info.name preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"添加" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [UserService addFriendNoticeWithUserId:info.userId completion:^(BOOL isSuccessful, NSError *error) {

            if (error) {
//                [self showInfomation:error.localizedDescription];
            }else{
//                [self showInfomation:@"已发送添加好友请求"];
                NSLog(@"已发送添加好友请求");
            }

        }];
    }];
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertName addAction:okBtn];
    [alertName addAction:cancelBtn];
    [self presentViewController:alertName animated:YES completion:nil];
    
 
}


@end
