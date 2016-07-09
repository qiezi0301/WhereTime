//
//  BMOBUtil.m
//  WhereTime
//
//  Created by 张家亮 on 16/3/19.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#import "BMOBUtil.h"
#import "constant.h"
#import <BmobSDK/Bmobfile.h>
#import <BmobSDK/BmobProFile.h>

@implementation BMOBUtil

//静态实例实现单例设计模式
static BMOBUtil *instance = nil;

//返回当前实例
+(BMOBUtil*)getInstance{
    NSLog(@"BMOBUtil中instance===%@",instance);
    if (instance ==nil) {
        instance = [[BMOBUtil alloc]init];
    }
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
//        self.uid = [self getUser].objectId;
        self.uid = [BmobUser getCurrentUser].objectId;
        NSLog(@"BMOB中uid===%@",self.uid);
        if (self.uid!=nil) {
            self.util = [DBUtil getInstance:self.uid];
        }
        return self;
    }
    return nil;
}

-(void)login:(NSString*)phoneNumber{
    NSLog(@"文本框输入的电话号码===%@",phoneNumber);
    BmobQuery *query = [BmobUser query];
    [query whereKey:PHONENUMBER equalTo:phoneNumber];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        for (BmobUser *user in array) {
            NSLog(@"objectid %@",user.objectId);
            //保存到本地
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setObject:user.objectId forKey:USERID];
            [userDefault setObject:user.username forKey:USERNAME];
            [userDefault setObject:user.password forKey:PASSWORD];
            [userDefault setObject:user.mobilePhoneNumber forKey:PHONENUMBER];
        }
        if (error) {
            //往UserTbl表添加一条phonenumber为phoneNumber的数据
            BmobUser *bUser = [[BmobUser alloc] init];
            [bUser setUsername:phoneNumber];
            [bUser setPassword:@"19991202"];
            [bUser setMobilePhoneNumber:phoneNumber];
            
            
            [bUser signUpInBackgroundWithBlock:^ (BOOL isSuccessful, NSError *error){
                if (isSuccessful){
                    NSLog(@"Sign up successfully");
                    //将电话号码保存到本地
                    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                    [userDefault setObject:phoneNumber forKey:PHONENUMBER];
                    
                    [self.delegate notify:YES andPhoneNumber:phoneNumber];
                    NSLog(@"生成新用户成功,将%@通知给代理",phoneNumber);
                } else {
                    NSLog(@"%@",error);
                    NSLog(@"生成新用户失败");
                    [self.delegate notify:NO andPhoneNumber:nil];
                }
            }];

        }
    }];
}

-(void)login:(NSString*)phoneNumber andPassword:(NSString*)pwd{
    NSLog(@"文本框输入的电话号码===%@,%@",phoneNumber,pwd);
    
    [BmobUser loginInbackgroundWithAccount:phoneNumber andPassword:pwd block:^(BmobUser *user, NSError *error) {
        if (user) {
            NSLog(@"%@",user);
            BmobUser *bUser = [BmobUser getCurrentUser];
            
            //保存到本地
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setObject:bUser.objectId forKey:USERID];
            [userDefault setObject:bUser.username forKey:USERNAME];
            [userDefault setObject:bUser.password forKey:PASSWORD];
            [userDefault setObject:bUser.mobilePhoneNumber forKey:PHONENUMBER];
            
            [self.delegate notify:YES andPhoneNumber:phoneNumber];
            //创建表
            [DBUtil getInstance:bUser.objectId];
            NSLog(@"登录成功，将%@通知给代理",phoneNumber);
        } else {
            NSLog(@"%@",error);
            [self.delegate notify:NO andPhoneNumber:phoneNumber];
        }
    }];
    
}

//等出
-(void)logout{
    [self.util clearnInstance];
    instance = nil;
    [BmobUser logout];
    NSLog(@"执行登出方法");
}

-(WTUserModel*)getUser{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *objectId = [userDefaults objectForKey:USERID];
    if (objectId == nil) {
        return nil;
    }else{
        WTUserModel *u = [[WTUserModel alloc]init];
        NSString *userName = [userDefaults objectForKey:USERNAME];
        NSString *password = [userDefaults objectForKey:PASSWORD];
        NSString *phoneNumber = [userDefaults objectForKey:PHONENUMBER];

        u.objectId = objectId;
        u.userName = userName;
        u.password = password;
        u.phoneNumber = phoneNumber;

        return u;
    }
    
}

//更新密码

-(void)updatePwd:(NSString*)uid andPwd:(NSString*)pwd{
    BmobQuery   *bquery = [BmobQuery queryWithClassName:WTUSERTABLE];
    [bquery getObjectInBackgroundWithId:uid block:^(BmobObject *object,NSError *error){
        if (error){
            //进行错误处理
        }else{
            if (object) {
                //此处是更新操作
                [object setObject:pwd forKey:@"password"];
                [object updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                    if (isSuccessful) {
                        NSLog(@"更新密码成功");
                    } else {
                        NSLog(@"更新密码失败%@",error);
                    }
                }];
            }
        }
    }];
}


#pragma mark - 本地添加或更新到服务器
-(void)addOrUpdateToBmob:(NSString*)uid andAddDate:(NSString*)addDate{
    
    self.util = [DBUtil getInstance:self.uid];
    NSLog(@"bmobUtil中uid===%@",self.uid);
    
    //通过UID 和addDate取出今天数据对象------------------------------------
    WTPhotoModel *up = [self.util queryPhotoById:uid andAddDate:addDate];
    NSLog(@"添加今天数据对象up.addDate==%@",up.addDate);
    
    //通过UID 和addDate查询服务器是否有数据
    BmobQuery   *bquery = [BmobQuery queryWithClassName:WTPHOTOTABLE];
    [bquery whereKey:@"userID" equalTo:uid];
    [bquery whereKey:@"addDate" equalTo:up.addDate];
    
    //查询多条数据
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        //通过objectId判断是否网络同步的数据
        NSLog(@"array.count==%lu",(unsigned long)array.count);
        if (array.count==0 || error) {
            //服务器没有这条数据---直接上传
            [self uploadFile:up andBmobObject:nil];
        }else{
            //服务器有这条数据---更新数据
            for (BmobObject *obj in array) {
                [self uploadFile:up andBmobObject:obj];
            }
        }
    }];
    
}


#pragma mark - 上传图片到服务器
-(void)uploadFile:(WTPhotoModel*)up andBmobObject:(BmobObject*)obj{
    
    //获取图片
    NSString *fileString = [NSString stringWithFormat:@"%@/Documents/%@",NSHomeDirectory(),up.pic_path];
    NSLog(@"上传图片path＝＝%@",fileString);
    //创建BmobFile对象
    BmobFile *file1 = [[BmobFile alloc] initWithFilePath:fileString];
    [file1 saveInBackgroundByDataSharding:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            //如果成功，保存文件到userFile
            NSLog(@"上传图片成功");
            if (obj==nil) {
                [self addFMDBToBmob:up andBmobFile:file1];
            }else{
                [self upDateFMDBToBmob:[obj objectId] andUpDate:up.updatedAtNew andBmobFile:file1];
            }
        }else{
            //失败，打印错误信息
            NSLog(@"error: %@",[error description]);
        }
    } ];
    
}


#pragma mark - 服务器同步相片到本地
-(void)syncBmonToFMDB:(NSString*)userID{
    //实例化工具类
    self.util = [DBUtil getInstance:self.uid];
    
    //查询PhotoTbl表
    BmobQuery   *bquery = [BmobQuery queryWithClassName:WTPHOTOTABLE];
    [bquery whereKey:@"userID" equalTo:userID];
    
    //根据添加数据顺序查询
    [bquery orderByAscending:@"createAt"];
    
    //通过userid查询本地数据库
    self.datasource  = [NSMutableArray arrayWithCapacity:10];
    
    //查询多条数据
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        NSLog(@"查询Bmob数据库条数==%lu",(unsigned long)array.count);
        NSMutableArray *photoArr = [self.util queryPhotoById:userID];
        
        if (error) {
            NSLog(@"服务器同步相片到本地>>查询数据库表出错error==%@",error);
            //进行错误处理
        }else{
            if (array.count == 0) {
                if (photoArr.count ==0) {
                    [MBProgressHUD showError:@"您还没数据呢"];
                }else{
                    [self addFMDBToBmob:self.uid];
                }
            }else{
                if(photoArr.count ==0){
                    [MBProgressHUD showError:@"更新到本地"];
                    for (BmobObject *obj in array) {
                        [self syncBmobToFMDB:obj andDBUtil:self.util];
                    }
                }else{
                    [MBProgressHUD showError:@"同步数据，请耐心等待"];
                    for (BmobObject *obj in array) {
                        [self syncBmobToFMDB:obj andDBUtil:self.util];
                    }
                    [self syncFMDBToBmob:self.uid];

                }
            }
        }
    }];
    
}

#pragma mark - 同步朋友相片到本地
-(void)syncFriend:(NSString*)friendUid{
    //实例化工具类
    self.friendUtil = [[DBUtil alloc]init:friendUid];
    
    //查询PhotoTbl表
    BmobQuery   *bquery = [BmobQuery queryWithClassName:WTPHOTOTABLE];
    [bquery whereKey:@"userID" equalTo:friendUid];
    
    //根据添加数据顺序查询
    [bquery orderByAscending:@"createAt"];
    
    //通过userid查询本地数据库
    self.datasource  = [NSMutableArray arrayWithCapacity:10];
    
    //查询多条数据
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        NSLog(@"查询Bmob数据库条数==%lu",(unsigned long)array.count);
        if (error) {
            NSLog(@"服务器同步相片到本地>>查询数据库表出错error==%@",error);
            //进行错误处理
        }else{
            if (array.count == 0) {
                [MBProgressHUD showError:@"好友没相片"];
            }else{
                for (BmobObject *obj in array) {
                    [self syncBmobToFMDB:obj andDBUtil:self.friendUtil];
                }
            }
        }
    }];
    
}



#pragma mark - 本地上传到服务器
-(void)addFMDBToBmob:(NSString*)uid{
    //实例化工具类
    self.util = [DBUtil getInstance:self.uid];
    //通过UID查询本地有几条数据
    NSMutableArray *photoArr = [self.util queryPhotoById:uid];
    NSLog(@"本地图片数量===>%lu",(unsigned long)photoArr.count);
    //循环执行本地每条数据
    for (NSString *string in photoArr) {
        NSUInteger idx = [photoArr indexOfObject:string];
        //获取本地当前数据对象
        WTPhotoModel *p = [photoArr objectAtIndex:idx];
        [self uploadFile:p andBmobObject:nil];

    }
}

#pragma mark - 本地-->云端
-(void)syncFMDBToBmob:(NSString*)uid{
    //实例化工具类
    self.util = [DBUtil getInstance:self.uid];
    //通过UID查询本地有几条数据
    NSMutableArray *photoArr = [self.util queryPhotoById:uid];
    NSLog(@"本地图片数量===>%lu",(unsigned long)photoArr.count);
    
    //循环执行本地每条数据
    for (NSString *string in photoArr) {
        
        //获取本地当前数据对象
        NSUInteger idx = [photoArr indexOfObject:string];
        WTPhotoModel *p = [photoArr objectAtIndex:idx];
        
        //通过UID查询服务器有几条数据
        BmobQuery *bquery = [BmobQuery queryWithClassName:WTPHOTOTABLE];
        [bquery whereKey:@"userID" equalTo:uid];
        [bquery whereKey:@"addDate" equalTo:p.addDate];
        
        //查询多条数据
        [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
            NSLog(@"查询BMOB中图片数量array.count==%lu",(unsigned long)array.count);
            //服务器没有这条数据直接上传
            if (array.count==0) {
                [self uploadFile:p andBmobObject:nil];
            }else if (array.count==1){
                //服务器有这条数据
                for (BmobObject *obj in array) {
                    NSLog(@"匹配服务器添加日期>>>>>>>>>>>>>>>>>>==%@==%@",p.addDate,[obj objectForKey:@"addDate"]);
                    [self comparisonDate:p andObj:obj andDBUtil:self.util];
                }
            }
            
        }];
    }
}

//服务器同步到本地
-(void)syncBmobToFMDB:(BmobObject *)obj andDBUtil:(DBUtil *)util{
    
    NSString *oid = [obj objectId];
    NSString *uid = [obj objectForKey:@"userID"];
    NSString *addDate =[obj objectForKey:@"addDate"];
    NSString *updatedAt = [obj objectForKey:@"newDateAt"] ;
    BmobFile *file = [obj objectForKey:@"photoImage"];
    NSString *url = file.url;
    
    WTPhotoModel *p = [util queryPhotoById:uid andAddDate:addDate];
    NSLog(@"WTPhotoModel对象addDate==%@",p.addDate);
    NSLog(@"oid=%@,uid=%@,addDate=%@",oid,uid,addDate);
    
    if (p.addDate==nil) {
        NSLog(@"本地数据库没有这条数据，下载添加...地址==%@",url);
        //WTPhotoModel *p = [[WTPhotoModel alloc]init];
        p.objectId = oid;
        p.userID = uid;
        p.addDate = addDate;
        p.updatedAtNew = updatedAt;
        p.tag = 1;
        //下载相片
        [self downLoad:url andUserPhoto:p andDBUtil:util];
    }else{
        NSLog(@"本地数据库有,检查更新日期早晚来判断，本地最新就上传，服务器最新就下载");
        p.objectId = oid;
        [self comparisonDate:p andObj:obj andDBUtil:util];
    }
}

//比较当前对象日期
-(void)comparisonDate:(WTPhotoModel*)p andObj:(BmobObject *)obj andDBUtil:(DBUtil *)util{
    NSString *oid = [obj objectId];
    NSString *updatedAt = [obj objectForKey:@"newDateAt"] ;
    BmobFile *file = [obj objectForKey:@"photoImage"];
    NSString *url = file.url;
    p.objectId = oid;
    
    NSLog(@"obj.updatedAt = %@ ,up.updatedAtNew = %@", updatedAt, p.updatedAtNew);
    NSLog(@"obj.addDate = %@ ,up.addDate = %@", [obj objectForKey:@"addDate"] , p.addDate);

    // 比较两个日期的早晚顺序， 可用于日期的排序
    switch ([p.updatedAtNew compare:updatedAt]) {
        case NSOrderedAscending:
            
            NSLog(@"服务器最新，更新到本地");
            p.updatedAtNew = updatedAt;
            p.tag = 0;
            [self downLoad:url andUserPhoto:p andDBUtil:util];
            break;
            
        case NSOrderedSame:
            NSLog(@"比较日期相等,不更新..............................");
            break;
        case NSOrderedDescending:
            
            NSLog(@"本地最新，更新到服务器");
            //就从本地更新到服务器
            [self uploadFile:p andBmobObject:obj];
            break;
    }
}
/**
 *  <#Description#>
 *
 *  @param compare:updatedAt] <#compare:updatedAt] description#>
 *
 *  @return <#return value description#>


 */

//下载文件
-(void)downLoad:(NSString*)url andUserPhoto:(WTPhotoModel*)p andDBUtil:(DBUtil *)util{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        
        //取出图片名字保存到数据中
        NSString *fileName = [response suggestedFilename];
        NSLog(@"下载文件到本地地址: %@", filePath);
        NSLog(@"p.tag: %ld", (long)p.tag);
        p.pic_path = fileName;
        if (p.tag==0) {
            //更新一条本地数据
            [util UpdateUserPhoto:p];
        }else{
            [util addUserPhoto:p];
        }
        
        
    }];
    [downloadTask resume];
}

/**
 *  最新
 *
 *  @return <#return value description#>
 */

#pragma mark - 本地添加数据服务器
-(void)addFMDBToBmob:(WTPhotoModel*)up andBmobFile:(NSObject *)bfile{
    //添加数据
    BmobObject  *photoTbl = [BmobObject objectWithClassName:WTPHOTOTABLE];
    [photoTbl setObject:up.userID forKey:@"userID"];
    [photoTbl setObject:bfile forKey:@"photoImage"];
    [photoTbl setObject:up.addDate forKey:@"addDate"];
    [photoTbl setObject:up.updatedAtNew forKey:@"newDateAt"];
    //异步保存到服务器
    [photoTbl saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            NSLog(@"异部保存到服务器成功%@",photoTbl);
        } else if (error){
            //发生错误后的动作
            NSLog(@"%@",error);
        } else {
            NSLog(@"Unknow error");
        }
    }];
    
}

#pragma mark - 本地更新数据服务器
-(void)upDateFMDBToBmob:(NSString*)oid andUpDate:(NSString*)uda andBmobFile:(NSObject *)bfile{
    //此处是更新操作
    BmobObject *photoScoreChanged = [BmobObject objectWithoutDataWithClassName:WTPHOTOTABLE objectId:oid];
     NSLog(@"此处是更新操作%@",bfile);
    [photoScoreChanged setObject:bfile forKey:@"photoImage"];
    [photoScoreChanged setObject:uda forKey:@"newDateAt"];
    [photoScoreChanged updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        [MBProgressHUD hideHUD];
        if (isSuccessful) {
            NSLog(@"更新成功，以下为对象值，可以看到json里面的gender已经改变");
            NSLog(@"%@",photoScoreChanged);
        } else {
            NSLog(@"%@",error);
        }
    }];
}

/**
 *  <#Description#>
 *
 *  @return <#return value description#>

#pragma mark - 服务器添加数据本地
-(void)addBmobToFMDB:(WTPhotoModel *)p andImgUrl:(NSString *)url{
    //添加数据
    p.tag = 1;
    
    NSLog(@"本地数据库没有这条数据，正在下载添加...地址==%@",url);
    //下载相片
    [self downLoad:url andUserPhoto:p];
    
    
}

#pragma mark - 服务器更新数据本地
-(void)upDateBmobToFMDB:(NSString*)uid andObjectId:(NSString*)oid andAddDate:(NSString*)addDate andUpDate:(NSString*)uda andImgUrl:(NSString *)url{
    //此处是更新操作
    WTPhotoModel *p = [[WTPhotoModel alloc]init];
    p.userID = uid;
    p.addDate = addDate;
    p.updatedAtNew = uda;
    p.tag = 0;
    //下载相片
    [self downLoad:url andUserPhoto:p];
    
}
 */


@end
