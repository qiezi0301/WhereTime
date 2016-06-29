//
//  AddFriendViewController.m
//  WT
//
//  Created by Mac on 16/6/28.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#import "AddFriendViewController.h"


@interface AddFriendViewController()

@property (weak, nonatomic) IBOutlet UITextField *contactTextfield;
@property (weak, nonatomic) IBOutlet UITextView *ncTextView;

- (IBAction)sendAction;

@end


@implementation AddFriendViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendAction {
    
    BmobObject *feedbackObj = [[BmobObject alloc] initWithClassName:@"Feedback"];
    
    //联系方式
    [feedbackObj setObject:self.contactTextfield.text forKey:@"Contact"];
    
    //反馈内容
    [feedbackObj setObject:self.ncTextView.text forKey:@"content"];
    
    //保存反馈信息到Bmob云数据库中
    [feedbackObj saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            NSLog(@"保存成功");
            [self sendPush:self.ncTextView.text];
        }else{
            NSLog(@"保存失败");
        }
    }];
}

/**
 * 推送反馈信息给isDeveloper的设备
 * @param message 反馈信息
 */

-(void)sendPush:(NSString*) message {
    //发送推送
    BmobPush *push = [BmobPush push];
    BmobQuery *query = [BmobInstallation query];
    //条件为isDeveloper是true
    [query whereKey:@"isDeveloper" equalTo:[NSNumber numberWithBool:YES] ];
    [push setQuery:query];
    //推送内容为反馈的内容
    [push setMessage: message];
    [push sendPushInBackgroundWithBlock:^(BOOL isSuccessful, NSError *error) {
        NSLog(@"push error =====>%@",[error description]);
    }];
}

@end

