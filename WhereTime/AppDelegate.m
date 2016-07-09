//
//  AppDelegate.m
//  WhereTime
//
//  Created by 张家亮 on 16/3/10.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#import "AppDelegate.h"
#import <SMS_SDK/SMSSDK.h>
#import <BmobSDK/Bmob.h>
#import <BmobIMSDK/BmobIMSDK.h>
#import "BmobIMDemoPCH.h"
#import "UserService.h"

@interface AppDelegate ()<BmobIMDelegate>
@property (strong, nonatomic) BmobIM *sharedIM;
@property (copy  , nonatomic) NSString *userId;
@property (copy  , nonatomic) NSString *token;
@end

@implementation AppDelegate

#define kAppKey @"fb1bf5aa6ce30435ac4d174230f7d5ed" //@""
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [SMSSDK registerApp:@"f151a9c03dfd"
             withSecret:@"3959bf05ef3282acecf7ae56700483d9"];
    
    [Bmob registerWithAppKey:kAppKey];
    self.sharedIM = [BmobIM sharedBmobIM];
    [self.sharedIM registerWithAppKey:kAppKey];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.token = @"";
    
    self.sharedIM.delegate = self;
    //注册推送，iOS 8的推送机制与iOS 7有所不同，这里需要分别设置
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc]init];
        //注意：此处的Bundle ID要与你申请证书时填写的一致。
        categorys.identifier=@"cn.itjz.WT";
        
        UIUserNotificationSettings *userNotifiSetting = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound) categories:[NSSet setWithObjects:categorys,nil]];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:userNotifiSetting];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }else {
        //注册远程推送
//        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
//        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
    return YES;
}

//接收推送信息的处理服务
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    NSLog(@"userInfo %@",[userInfo description]);
    //    [BmobPush handlePush:userInfo];
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    BmobUser *user = [BmobUser getCurrentUser];
    if (user) {
        NSString *string = [[NSString alloc] initWithData:deviceToken encoding:NSUTF8StringEncoding];
        self.token = [[[string stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""];
        [self connectToServer];
    }
    
    
    //注册成功后上传Token至服务器
    BmobInstallation  *currentIntallation = [BmobInstallation installation];
    [currentIntallation setDeviceTokenFromData:deviceToken];
    [currentIntallation saveInBackground];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

//进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if ([self.sharedIM isConnected]) {
        [self.sharedIM disconnect];
    }
}

//进入前台
- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if (self.userId && self.userId.length > 0) {
        [self connectToServer];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)connectToServer{
    [self.sharedIM setupBelongId:self.userId];
    [self.sharedIM setupDeviceToken:self.token];
//    [self.sharedIM connect];//连接服务器
}


//另一方面，已经连接到服务器上了，就可以收到别人发送过来的消息，这是需要在另一个方法处理
-(void)didRecieveMessage:(BmobIMMessage *)message withIM:(BmobIM *)im{
    
    BmobIMUserInfo *userInfo = [self.sharedIM userInfoWithUserId:message.fromId];
    if (!userInfo) {
        [UserService loadUserWithUserId:message.fromId completion:^(BmobIMUserInfo *result, NSError *error) {
            if (result) {
                [self.sharedIM saveUserInfo:result];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNewMessageFromer object:nil];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kNewMessagesNotifacation object:message];
        }];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNewMessagesNotifacation object:message];
    }
}

//接收消息
-(void)didGetOfflineMessagesWithIM:(BmobIM *)im{
    
    NSArray *objectIds = [self.sharedIM allConversationUsersIds];
    if (objectIds && objectIds.count > 0) {
        [UserService loadUsersWithUserIds:objectIds completion:^(NSArray *array, NSError *error) {
            if (array && array.count > 0) {
                [self.sharedIM saveUserInfos:array];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNewMessageFromer object:nil];
            }
        }];
    }
    
}

@end
