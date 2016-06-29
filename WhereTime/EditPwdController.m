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
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPwdField;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
- (IBAction)saveAction;

@end

@implementation EditPwdController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bmobUtil = [[BMOBUtil alloc]init];

    
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
    NSLog(@"保存");
    if ([self.pwdField.text isEqualToString:self.confirmPwdField.text]) {
        WTUserModel *u = [self.bmobUtil getUser];
        NSString *userID = u.objectId;
        [self.bmobUtil updatePwd:userID andPwd:self.pwdField.text];
        [MBProgressHUD showMessage:@"密码保存成功"];
        [self.navigationController popViewControllerAnimated:YES];
        NSLog(@"密码一样,保存成功");
        
//        [self performSegueWithIdentifier:@"LoginToContact" sender:nil];
    }else{
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"保存密码失败" message:[NSString stringWithFormat:@"两次密码输入不一样"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alertView addAction:okBtn];
        [self presentViewController:alertView animated:YES completion:nil];
    }
    
}
@end
