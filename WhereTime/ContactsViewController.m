//
//  ContactsViewController.m
//  WT
//
//  Created by Mac on 16/7/2.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#import "ContactsViewController.h"
#import "UserInfoTableViewCell.h"
#import "ViewUtil.h"
#import "UserService.h"
#import "FriendPhotoViewController.h"

@interface ContactsViewController()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
//@property (weak, nonatomic) IBOutlet UIView *inviteView;
@property (strong, nonatomic) NSMutableArray *userArray;

@property(nonatomic,strong)BMOBUtil *friendBmobUtil;

@end

@implementation ContactsViewController
static NSString *cellId = @"UserInfoCellID";

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self setupSubviews];
    _userArray = [[NSMutableArray alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self loadUserFriends];
}

-(void)setupSubviews{
    
    //    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toMessagesVC)];
    //    [self.inviteView addGestureRecognizer:tapRecognizer];
    
    //    UINib *nib = [UINib nibWithNibName:@"UserInfoTableViewCell" bundle:nil];
    //    [self.tableView registerNib:nib forCellReuseIdentifier:cellId];
    self.tableView.rowHeight = 60;
}


-(void)loadUserFriends{
    [UserService friendsWithCompletion:^(NSArray *array, NSError *error) {
        
        if (error) {
            [self showInfomation:error.localizedDescription];
        }else{
            BmobUser *loginUser = [BmobUser getCurrentUser];
            NSMutableArray *result  = [NSMutableArray array];
            for (BmobObject *obj in array) {
                
                BmobUser *friend = nil;
                if ([[(BmobUser *)[obj objectForKey:@"user"] objectId] isEqualToString:loginUser.objectId]) {
                    friend = [obj objectForKey:@"friendUser"];
                }else{
                    friend = [obj objectForKey:@"user"];
                }
                BmobIMUserInfo *info = [BmobIMUserInfo userInfoWithBmobUser:friend];
                
                [result addObject:info];
            }
            if (result && result.count > 0) {
                [self.userArray setArray:result];
                [self.tableView reloadData];
                NSLog(@"读取通知信息%lu",(unsigned long)array.count);
            }
            
        }
    }];
}

-(void)toMessagesVC{
    [self performSegueWithIdentifier:@"toMessageVC" sender:nil];
}

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"self.dataArray.count----->%lu",(unsigned long)self.userArray.count);
    return self.userArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UserInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if(cell == nil) {
        cell = [[UserInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    BmobIMUserInfo *info = self.userArray[indexPath.row];
    [cell setInfo:info];
    
    
    NSLog(@"BmobIMUserInfo *info === %@",info);
    return cell;
}

#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BmobIMUserInfo *info = self.userArray[indexPath.row];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FriendPhotoViewController *fvc = [storyBoard instantiateViewControllerWithIdentifier:@"FriendPhotoViewController"];
    fvc.info = info;
    fvc.friendUId = info.userId;
    
    //同步好友图片
    self.friendBmobUtil = [BMOBUtil getInstance];
    [self.friendBmobUtil syncFriend:info.userId];
    
    [self.navigationController pushViewController:fvc animated:YES];
    
}


#pragma mark - Navigation



@end
