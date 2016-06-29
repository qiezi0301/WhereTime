//
//  WTPhotoModel.h
//  WhereTime
//
//  Created by 张家亮 on 16/3/19.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BmobSDK/Bmob.h>

@interface WTPhotoModel : BmobObject
//@property(nonatomic,copy)NSData *pic_path;
@property(nonatomic,copy)NSString *pic_path;
@property(nonatomic,copy)NSString *userID;
@property(nonatomic,copy)NSString *addDate;
@property(nonatomic,copy)NSString *updatedAtNew;
@property(nonatomic) NSInteger tag; 
@end
