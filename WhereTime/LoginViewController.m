
//
//  LoginViewController.m
//  WhereTime
//
//  Created by 张家亮 on 16/3/10.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#import "LoginViewController.h"
#import "constant.h"
#import "MBProgressHUD+MJ.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *codeField;
@property (weak, nonatomic) IBOutlet UIButton *getCodeBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

- (IBAction)getCodeAction;
- (IBAction)loginAction;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置导航栏透明
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    //隐藏返回按钮
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.leftBarButtonItem = leftBtn;
    
    self.bmobUtil = [BMOBUtil getInstance];
    self.bmobUtil.delegate = self;
    //判断是否登录
    WTUserModel *u = [self.bmobUtil getUser];
    if (u!=nil) {
        self.phoneField.text = u.phoneNumber;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // 取得目标控制器
//    UIViewController *photoVC = segue.destinationViewController;
}


- (IBAction)getCodeAction {
    
    NSString *phoneNumber = self.phoneField.text;
    [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:phoneNumber zone:@"86" customIdentifier:nil result:^(NSError *error) {
        if (error == nil) {
            UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"验证码发送成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            [alertView addAction:okBtn];
            [self presentViewController:alertView animated:YES completion:nil];
        }else{
            UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"验证码发送失败" message:[NSString stringWithFormat:@"%@",[error.userInfo objectForKey:@"getVerificationCode"]] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            [alertView addAction:okBtn];
            [self presentViewController:alertView animated:YES completion:nil];
            
        }
        
    }];

}

- (IBAction)loginAction {
    NSString *phoneNumber = self.phoneField.text;
    NSLog(@"输出电话==%@",phoneNumber);
    NSString *codeNumber = self.codeField.text;
    //短信验证
    //显示蒙板（遮罩）
    [MBProgressHUD showMessage:@"验证中..."];
    [SMSSDK commitVerificationCode:codeNumber phoneNumber:phoneNumber zone:@"86" result:^(NSError *error) {
        if (error==nil) {
            [self.bmobUtil login:phoneNumber];
        }else{
            [self.bmobUtil login:phoneNumber andPassword:codeNumber];
        }
        
    }];
    
}

-(void)notify:(BOOL)b andPhoneNumber:(NSString *)phoneNumber{
    NSLog(@"接收通知");
    [MBProgressHUD hideHUD];
    if (b) {
        WTUserModel *u = [self.bmobUtil getUser];
        NSString *userID = u.objectId;
        NSLog(@"接收通知===>%@登录成功",userID);
        
        //开始跳转页面
        [MBProgressHUD showMessage:@"正在跳转页面..."];
        //模拟两秒跳转，以后要发送网络请求
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //移除遮罩
            [MBProgressHUD hideHUD];
            [self performSegueWithIdentifier:@"loginToPhoto" sender:nil];
        });
    }else{
        [MBProgressHUD showError:@"手机或密码不正确"];
        NSLog(@"登录失败");
    }
}

@end
