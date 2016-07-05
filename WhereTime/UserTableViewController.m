
//
//  UserTableViewController.m
//  WhereTime
//
//  Created by 张家亮 on 16/3/10.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#import "UserTableViewController.h"

@interface UserTableViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)NSArray *dataList;
@property(nonatomic,strong)NSArray *detailData;
@property(nonatomic,strong)NSString *userID;

@end

@implementation UserTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    BmobUser *bUser = [BmobUser getCurrentUser];
    NSString *phoneNumber = bUser.mobilePhoneNumber;
    NSString *pwd = bUser.password;
    self.userID = bUser.objectId;
    
    NSLog(@"phoneNumber===>%@",phoneNumber);
    self.dataList = @[phoneNumber, @"密码", @"同步"];
    if (pwd==nil) {
        self.detailData =@[@"退出登录", @"请设置密码", @"云端<->本地"];
    }else{
        self.detailData =@[@"退出登录", @"修改密码", @"云端<->本地"];
    }
    
    //设置tableView不能滚动
    [self.tableView setScrollEnabled:NO];
    
    //去掉多余的线
    self.tableView.tableFooterView = [[UIView alloc]init];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userCell" forIndexPath:indexPath];
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    //获取数据源
    NSString *numberString = self.dataList[indexPath.row];
    NSString *detailData = self.detailData[indexPath.row];
    //设置单元格内容
    cell.textLabel.text = numberString;
    cell.detailTextLabel.text = detailData;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - 单元格点击方法

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0 :{
            UIAlertController *alertName = [UIAlertController alertControllerWithTitle:@"退出登录" message:@"是否真的退出" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.bmobUtil logout];
                //[self.navigationController popToRootViewControllerAnimated:YES];
                [self performSegueWithIdentifier:@"PhotoTologin" sender:nil];
            }];
            UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alertName addAction:okBtn];
            [alertName addAction:cancelBtn];
            [self presentViewController:alertName animated:YES completion:nil];
        }
            break;
            
        case 1 :{
            [self performSegueWithIdentifier:@"userTableToEditPwd" sender:nil];
        }
            break;
            
        case 2 :{
            //同步到本地
            [self.bmobUtil syncBmonToFMDB:self.userID];
        }
            break;
            
        default:
            break;
    }
    
    
}



@end
