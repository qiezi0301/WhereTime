//
//  DBUtil.m
//  WhereTime
//
//  Created by 张家亮 on 16/3/19.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#import "DBUtil.h"


@implementation DBUtil

//静态实例实现单例设计模式
static DBUtil *instance = nil;


//返回当前实例
+(DBUtil*)getInstance:(NSString*)uid{
        NSLog(@"util中instance===%@",instance);
        if (instance ==nil) {
            instance = [[DBUtil alloc]init:uid];
        }
    return instance;
}

//清除instance
-(void)clearnInstance{
    instance = nil;
    NSLog(@"清除instance===%@",instance);
}

//初始化
-(instancetype)init:(NSString*)uid{
    self = [super init];
    if (self) {
        NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [docPaths objectAtIndex:0];
        
        //创建数据库路径
        self.path = [path stringByAppendingPathComponent:@"whereTime.db"];
        self.db = [FMDatabase databaseWithPath:self.path];
        NSLog(@"util中uid===%@",uid);
        if (uid!=nil) {
            //设置用户表名字
            self.tblName = [@"PT" stringByAppendingString:uid];
            NSLog(@"self.tblName===%@",self.tblName);
            //创建表
            [self open];
            [self createTable];
            [self close];
        }

    }
    return self;
}

//打开库
-(void)open{
    if (![self.db open]) {
        return;
    }
}

//关闭库
-(void)close{
    [self.db close];
}

//创建表
-(void)createTable{
    NSString *sql1 = [NSString stringWithFormat:@"create table if not exists %@ (objectid text,pic_path text,uid text,createdAt text,updatedAt text)",self.tblName];
    BOOL r =[self.db executeUpdate:sql1];
    if (r) {
        NSLog(@"创建表成功");
    }else{
        NSLog(@"创建表失败");
    }
}

/**
 *  <#Description#>
 *
 *  @return <#return value description#>

//添加之前先删除所有相片
-(void)deleteAllPhoto{
    [self open];
    NSString *sql = [NSString stringWithFormat:@"delete from %@",self.tblName];
    [self.db executeUpdate:sql];
    NSLog(@"删除数据库所有图片");
    [self close];
}
 */

//服务器下载添加相片
-(void)addUserPhoto:(WTPhotoModel*)p{
    //统一把时间转换字符串
    NSLog(@"开始添加数据到本地用户表------------------------------------------------");
    [self open];
    NSString *sql = [NSString stringWithFormat:@"insert into %@ (objectid,pic_path,uid,createdAt,updatedAt)values(?,?,?,?,?)",self.tblName];
    BOOL r = [self.db executeUpdate:sql,p.objectId,p.pic_path,p.userID,p.addDate,p.updatedAtNew];
    if (r) {
        NSLog(@"数据成功添加本地p.updatedAtNew==%@",p.updatedAtNew);
        [self.delegate isDownPhoto:YES andImage:p.pic_path];
    }else{
        NSLog(@"本地添加数据失败");
    }
    
    [self close];
}

//服务器下载更新相片
-(void)UpdateUserPhoto:(WTPhotoModel*)p{
    [self open];
    NSLog(@"开始更新数据到本地用户表------------------------------------------------");
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET objectid=? , updatedAt=? , pic_path=? WHERE uid=? and createdAt=?",self.tblName];
    BOOL r = [self.db executeUpdate:sql, p.objectId, p.updatedAtNew, p.pic_path, p.userID, p.addDate];
    if (r) {
        NSLog(@"更新相片成功objectId==%@",p.objectId);
        [self.delegate isDownPhoto:YES andImage:p.pic_path];
    }else{
        NSLog(@"更新相片失败");
        [self.delegate notify:NO];
    }
    [self close];
}

//拍照添加相片到本地
-(void)pickerAddUserPhoto:(WTPhotoModel*)p{
    //查询今天是否有数据
    BOOL isAddDate = [self queryPhotoById:p.userID andByAddDate:p.addDate];
    if (isAddDate) {
        //更新
        [self pickerUpdateUserPhoto:p];
    }else{
        //添加
        [self open];
        NSString *sql = [NSString stringWithFormat:@"insert into %@(pic_path,updatedAt,uid,createdAt)values(?,?,?,?)",self.tblName];
        BOOL r = [self.db executeUpdate:sql,p.pic_path,p.updatedAtNew,p.userID,p.addDate];
        if (r) {
            NSLog(@"拍照添加相片到数据库成功");
            [self.delegate notify:YES];
        }else{
            NSLog(@"拍照添加相片到数据库失败");
            [self.delegate notify:NO];
        }
        
        [self close];
    }

}

//拍照更新相片
-(void)pickerUpdateUserPhoto:(WTPhotoModel*)p{
    [self open];

    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET pic_path=?, updatedAt=? WHERE uid=? and createdAt=?",self.tblName];
    BOOL r = [self.db executeUpdate:sql,p.pic_path,p.updatedAtNew,p.userID,p.addDate];
    if (r) {
        NSLog(@"拍照更新相片到数据库成功");
        [self.delegate notify:YES];
    }else{
        NSLog(@"拍照更新相片到数据库失败");
        [self.delegate notify:NO];
    }
    
    [self close];
}

//根据UID查询
-(NSMutableArray*)queryPhotoById:(NSString*)uid{
    [self open];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE uid=? ORDER BY createdAt ASC",self.tblName];
    FMResultSet *s = [self.db executeQuery:sql,uid];
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:10];
   
    while ([s next]) {

        NSString *objectid = [s stringForColumn:@"objectid"];
        NSString *pic_path = [s stringForColumn:@"pic_path"];
        NSString *uid = [s stringForColumn:@"uid"];
        NSString *createdAt = [s stringForColumn:@"createdAt"];
        NSString *updatedAt = [s stringForColumn:@"updatedAt"];

        WTPhotoModel *p = [[WTPhotoModel alloc]init];
        p.objectId = objectid;
        p.pic_path = pic_path;
        p.userID = uid;
        p.addDate = createdAt;
        p.updatedAtNew = updatedAt;

        [temp addObject:p];
        
    }
    
    [self close];
    return temp;
}

//根据UID和添加日期查询今天的数据对象
-(WTPhotoModel*)queryPhotoById:(NSString*)uid andAddDate:(NSString*)addDate{
    [self open];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE uid=? and createdAt=? ORDER BY createdAt ASC",self.tblName];
    FMResultSet *s = [self.db executeQuery:sql,uid,addDate];
    WTPhotoModel *p = [[WTPhotoModel alloc]init];
    if ([s next]) {
        NSString *uid = [s stringForColumn:@"uid"];
        NSString *objectid = [s stringForColumn:@"objectid"];
        NSString *pic_path = [s stringForColumn:@"pic_path"];
        NSString *createdAt = [s stringForColumn:@"createdAt"];
        NSString *updatedAt = [s stringForColumn:@"updatedAt"];
        
        p.userID = uid;
        p.objectId = objectid;
        p.pic_path = pic_path;
        p.addDate = createdAt;
        p.updatedAtNew = updatedAt;
        
        NSLog(@"objectid=%@",objectid);
        
    }
    [self close];
    return p;
}

//根据UID 和addDate 查询
-(BOOL)queryPhotoById:(NSString*)uid andByAddDate:(NSString*)addDate{
    [self open];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE uid=? and createdAt=? ORDER BY createdAt ASC",self.tblName];
    FMResultSet *s = [self.db executeQuery:sql,uid,addDate];
    BOOL r = [s next];
    [self close];
    return r;
}

/*
//根据UID查询 服务器和本地更新时间是否一致
-(BOOL)queryPhotoById:(NSString*)uid andByAddDate:(NSString*)addDate andByUpdatedAt:(NSString*)updatedAt{
    [self open];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE uid=? and createdAt=? ORDER BY createdAt ASC",self.tblName];
    FMResultSet *s = [self.db executeQuery:sql,uid,addDate];
    BOOL isUpdatedAt = [s next];
    
    //获取本地更新时间
    NSString *udAt = [s stringForColumn:@"updatedAt"];
    NSLog(@"本地udAt = %@,服务器updatedAt=%@",udAt,updatedAt);
    // 比较两个日期的早晚顺序， 可用于日期的排序
    switch ([udAt compare:updatedAt]) {
        case NSOrderedAscending:
            NSLog(@"本地udAt 比 服务器updatedAt 早");
            //就从服务器上更新到本地
            isUpdatedAt = NO;
            break;
        case NSOrderedSame:
            NSLog(@"本地udAt 与 服务器updatedAt 相等");
            break;
        case NSOrderedDescending:
            NSLog(@"本地udAt 比 服务器updatedAt 晚");
            //就从本地更新到服务器
            isUpdatedAt = YES;
            break;
    }
    
    [self close];
    return isUpdatedAt;
}
*/
//日期格式化
//- (NSDate *)dateFromString:(NSString *)dateString{
//    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
////    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
//    fmt.dateFormat = @"yyyy-MM-dd";
//    NSDate *destDate= [fmt dateFromString:dateString];
//    return destDate;
//    
//}

- (NSString *)stringFromDate:(NSDate *)date{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    NSString *destDateString = [fmt stringFromDate:date];
    return destDateString;
}

- (NSString *)stringFromDateAll:(NSDate *)date{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *destDateString = [fmt stringFromDate:date];
    return destDateString;
}

@end
