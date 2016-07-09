//
//  FriendPhotoViewController.h
//  WT
//
//  Created by Mac on 16/7/6.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#import "PhotoViewController.h"


@interface FriendPhotoViewController : PhotoViewController
@property (strong, nonatomic) NSString *friendUId;
@property(strong,nonatomic) BmobIMUserInfo *info;
@end
