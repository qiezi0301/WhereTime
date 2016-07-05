//
//  SystemCell.m
//  WT
//
//  Created by Mac on 16/7/3.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#import "SystemCell.h"

@interface SystemCell()
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@end

@implementation SystemCell

+(instancetype)systemCellWithTableView:(UITableView*)tableView{
    static NSString *cellID = @"mycell";
    SystemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SystemCell" owner:self options:nil] lastObject];
    }
    return cell;
}

-(void)setCellData:(NSString *)cellData{
    _cellData = cellData;
    self.contentLabel.text = cellData;
}

@end
