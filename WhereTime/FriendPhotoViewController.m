//
//  FriendPhotoViewController.m
//  WT
//
//  Created by Mac on 16/7/6.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#import "FriendPhotoViewController.h"
#import "BaseViewController.h"

@interface FriendPhotoViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *FriendPhotoImage;
@property (weak, nonatomic) IBOutlet UIButton *friendBtn;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;

@property(nonatomic,strong)NSMutableArray *friendDatasource;
@property(nonatomic,strong)BMOBUtil *friendBmobUtil;
@property(nonatomic,strong)DBUtil *friendUtil;

@end

@implementation FriendPhotoViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"self.friendUId===%@",self.friendUId);
    
    //查询数据
    self.friendDatasource = [NSMutableArray arrayWithCapacity:10];
    self.friendUtil = [[DBUtil alloc]init:self.friendUId];
    self.friendDatasource = [self.friendUtil queryPhotoById:self.friendUId];
    NSLog(@"本地图片数量===>%lu",(unsigned long)self.friendDatasource.count);
    
    //初始化图片
    if (self.friendDatasource.count>0) {
        NSUInteger num =self.friendDatasource.count;
        WTPhotoModel *up = [self.friendDatasource objectAtIndex:num-1];
        
        NSString *path = [NSString stringWithFormat:@"%@/Documents/%@",NSHomeDirectory(),up.pic_path];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        NSLog(@"image===%@",path);
        self.FriendPhotoImage.image = image;
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)friendAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)playAction:(id)sender {
    
    //查询数据
    self.friendDatasource = [self.friendUtil queryPhotoById:self.friendUId];
    NSLog(@"本地数据库数量%lu",(unsigned long)self.friendDatasource.count);
    
    if (self.friendDatasource.count == 0) {
        [MBProgressHUD showError:@"没靓照，更新或拍一张吧"];
    }else{
        self.playBtn.hidden  = YES;
        self.friendBtn.hidden = YES;
        //判断重复点击播放
        if (self.FriendPhotoImage.isAnimating) return;
        
        NSMutableArray *tempArrayM = [NSMutableArray array];
        for (NSString *string in self.friendDatasource) {
            NSUInteger idx = [self.friendDatasource indexOfObject:string];
            WTPhotoModel *up = [self.friendDatasource objectAtIndex:idx];
            NSString *path = [NSString stringWithFormat:@"%@/Documents/%@",NSHomeDirectory(),up.pic_path];
            NSLog(@"idx--->%lu",(unsigned long)idx);
            
            //self.navigationItem.title = [NSString stringWithFormat:@"%lu",(unsigned long)idx];
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            //UIImage *image = [UIImage imageWithData:up.pic_path];
            [tempArrayM addObject:image];
        }
        
        self.FriendPhotoImage.animationImages = tempArrayM;
        //动画播放速度及次数
        self.FriendPhotoImage.animationDuration = self.FriendPhotoImage.animationImages.count * 0.2;
        self.FriendPhotoImage.animationRepeatCount = 1;
        
        //开始播放
        [self.FriendPhotoImage startAnimating];
        
        //动画播放完毕以后，清空animationImages
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.FriendPhotoImage.animationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.FriendPhotoImage.animationImages = nil;
            self.playBtn.hidden  = NO;
            self.friendBtn.hidden = NO;
        });
    }
    
}

@end
