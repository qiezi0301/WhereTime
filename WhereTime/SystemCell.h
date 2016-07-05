//
//  SystemCell.h
//  WT
//
//  Created by Mac on 16/7/3.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SystemCell : UITableViewCell

@property(nonatomic,copy)NSString *cellData;

+(instancetype)systemCellWithTableView:(UITableView*)tableView;

@end
