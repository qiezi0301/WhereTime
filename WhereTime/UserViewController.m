//
//  UserViewController.m
//  WT
//
//  Created by Mac on 16/7/2.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#import "UserViewController.h"
#import "UserInfoTableViewCell.h"
#import "UserService.h"
#import "UserDetailViewController.h"


@interface UserViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *userArray;
@end

static NSString *cellId = @"UserInfoCellID";
@implementation UserViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    _userArray = [[NSMutableArray alloc] init];
    [self loadUsers];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)hidesBottomBarWhenPushed{
    return YES;
}


-(void)setupSubviews{
    self.searchBar.delegate = self;
}

#pragma mark -加载好友
-(void)loadUsers{
    [self showLoading];
    [UserService loadUsersWithDate:[NSDate date] completion:^(NSArray *array, NSError *error) {
        NSLog(@"开始加载用户表中用户%lu",(unsigned long)array.count);
        if (error) {
            [self showInfomation:error.localizedDescription];
        }else{
            if (array && array.count > 0) {
                [self.userArray setArray:array];
                [self.tableView reloadData];
            }
            [self hideLoading];
        }
    }];
}


#pragma mark - UITableView Datasource

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




#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BmobIMUserInfo *info = self.userArray[indexPath.row];
    [self performSegueWithIdentifier:@"toUserDetail" sender:info];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - search delegate


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if (searchBar.text.length > 0) {
        [self showLoading];
        [UserService loadUsersWithDate:[NSDate date] keyword:searchBar.text completion:^(NSArray *array, NSError *error) {
            if (error) {
                [self showInfomation:error.localizedDescription];
            }else{
                if (array) {
                    [self.userArray setArray:array];
                    
                }else{
                    [self.userArray removeAllObjects];
                }
                [self.tableView reloadData];
                [self hideLoading];
            }
        } ];
        
    }
    [searchBar resignFirstResponder];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"toUserDetail"]) {
        UserDetailViewController *udvc = segue.destinationViewController;
        udvc.userInfo = sender;
    }
}


@end