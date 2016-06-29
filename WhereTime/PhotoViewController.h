//
//  PhotoViewController.h
//  WhereTime
//
//  Created by 张家亮 on 16/3/10.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMOBUtil.h"
#import "DBUtil.h"

@interface PhotoViewController : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate,DBUtilDelegate>

@property(nonatomic,strong)BMOBUtil *bmobUtil;
@property(nonatomic,strong)DBUtil *util;
@property(nonatomic,strong)NSMutableArray *datasource;
@property(nonatomic,strong)NSString *userId;
@property(nonatomic,strong)NSString * documentsDirectoryPath;


@end
