//
//  BMOBUtil.h
//  WhereTime
//
//  Created by 张家亮 on 16/3/19.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WTUserModel.h"
#import "WTPhotoModel.h"
#import "DBUtil.h"
#import "AFNetworking.h"
#import "MBProgressHUD+MJ.h"


@protocol BMOBUtilDelegate <NSObject>

-(void)notify:(BOOL)b andPhoneNumber:(NSString*)phoneNumber;

@end

@interface BMOBUtil : NSObject
@property(nonatomic,weak)id <BMOBUtilDelegate> delegate;

@property(nonatomic,strong)DBUtil *util;
@property(nonatomic,strong)NSMutableArray *datasource;
@property(nonatomic,strong)NSDateFormatter *fmt;
@property(nonatomic,strong)BmobFile *bfile;
@property(nonatomic,strong)NSString *uid;
@property(nonatomic,strong)NSString *tblName;

//单例设计模式
+(BMOBUtil*)getInstance;

//登录
-(void)login:(NSString*)phoneNumber;
-(void)login:(NSString*)phoneNumber andPassword:(NSString*)pwd;

//登出
-(void)logout;

//获取用户信息
-(WTUserModel*)getUser;

#pragma mark - 本地添加或更新到服务器
-(void)addOrUpdateToBmob:(NSString*)uid andAddDate:(NSString*)addDate;

//根据uid同步数据
//-(void)syncData:(NSString*)userID;

//服务器同步到本地
-(void)syncBmonToFMDB:(NSString*)userID;

//本地同步到服务器
//-(void)syncFMDBToBmob:(NSString*)userID;
-(void)syncFMDBToBmob:(NSString*)uid;

//更新密码
-(void)updatePwd:(NSString*)uid andPwd:(NSString*)pwd;
@end
