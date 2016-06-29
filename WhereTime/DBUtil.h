//
//  DBUtil.h
//  WhereTime
//
//  Created by 张家亮 on 16/3/19.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabaseQueue.h"
#import "FMDatabase.h"

#import "WTPhotoModel.h"
#import "WTUserModel.h"



@protocol DBUtilDelegate <NSObject>

-(void)notify:(BOOL)b ;
-(void)isDownPhoto:(BOOL)b andImage:(NSString*)photoImage;

@end


@interface DBUtil : NSObject
@property(nonatomic,weak)id <DBUtilDelegate> delegate;

//数据库保存的位置
@property(nonatomic,strong)NSString *path;

//数据库表名字
@property(nonatomic,strong)NSString *tblName;

//数据库实例
@property(nonatomic,strong)FMDatabase *db;
//@property(nonatomic,assign)BOOL isUpdatedAt;

//单例设计模式
+(DBUtil*)getInstance:(NSString*)uid;

//清除instance
-(void)clearnInstance;

//打开库
-(void)open;

//关闭库
-(void)close;

//创建表
-(void)createTable;

//服务器下载添加相片
-(void)addUserPhoto:(WTPhotoModel*)p;
//服务器下载更新相片
-(void)UpdateUserPhoto:(WTPhotoModel*)p;

//拍照添加相片
-(void)pickerAddUserPhoto:(WTPhotoModel*)p;

//拍照更新相片
-(void)pickerUpdateUserPhoto:(WTPhotoModel*)p;

//删除所有相片
//-(void)deleteAllPhoto;

//查询相片
//-(NSMutableArray*)queryPhoto;

//根据UID查询
-(NSMutableArray*)queryPhotoById:(NSString*)uid;

//根据UID和添加日期查询今天的数据
-(WTPhotoModel*)queryPhotoById:(NSString*)uid andAddDate:(NSString*)addDate;

//根据UID和OID查询
-(BOOL)queryPhotoById:(NSString*)uid andByAddDate:(NSString*)addDate;

//根据UID查询 服务器和本地更新时间是否一致
//-(BOOL)queryPhotoById:(NSString*)uid andByAddDate:(NSString*)addDate andByUpdatedAt:(NSString*)updatedAt;

- (NSString *)stringFromDate:(NSDate *)date;
//- (NSDate *)dateFromString:(NSString *)dateString;
- (NSString *)stringFromDateAll:(NSDate *)date;
@end
