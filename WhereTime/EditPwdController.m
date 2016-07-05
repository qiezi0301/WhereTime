//
//  EditPwdController.m
//  WhereTime
//
//  Created by 张家亮 on 16/4/9.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#import "EditPwdController.h"
#import "MBProgressHUD+MJ.h"

@interface EditPwdController ()
@property (weak, nonatomic) IBOutlet UITextField *oldPwdField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPwdField;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
- (IBAction)saveAction;

@end

@implementation EditPwdController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)saveAction {
    
    if ([self.pwdField.text isEqualToString:self.confirmPwdField.text]) {
        BmobUser *user = [BmobUser getCurrentUser];
        [user updateCurrentUserPasswordWithOldPassword:self.oldPwdField.text newPassword:self.pwdField.text block:^(BOOL isSuccessful, NSError *error) {
            if (isSuccessful) {
                //用新密码登录
                [BmobUser loginInbackgroundWithAccount:user.username andPassword:self.pwdField.text block:^(BmobUser *user, NSError *error) {
                    if (error) {
                        NSLog(@"login error:%@",error);
                    } else {
                        [MBProgressHUD showMessage:@"密码保存成功"];
                        [self.navigationController popViewControllerAnimated:YES];
                        NSLog(@"user:%@",user);
                    }
                }];
            } else {
                NSLog(@"change password error:%@",error);
                [MBProgressHUD showError:@"旧密码不正确"];
            }
        }];

    }else{
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"保存密码失败" message:[NSString stringWithFormat:@"两次密码输入不一样"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alertView addAction:okBtn];
        [self presentViewController:alertView animated:YES completion:nil];
    }
    
}
@end
