//
//  PhotoViewController.m
//  WhereTime
//
//  Created by 张家亮 on 16/3/10.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#import "PhotoViewController.h"
#import "constant.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "Reachability.h"
#import <SystemConfiguration/SystemConfiguration.h>

@interface PhotoViewController ()

@property(nonatomic,strong)UIImagePickerController *picker;
@property (weak, nonatomic) IBOutlet UIImageView *photoImage;
@property (nonatomic, strong) Reachability *reach;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *userBtn;
@property (weak, nonatomic) IBOutlet UIButton *pickerBtn;
//@property (weak, nonatomic) IBOutlet UIButton *syncBtn;
@property (weak, nonatomic) IBOutlet UIButton *friendBtn;

@end

@implementation PhotoViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置导航栏透明
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    self.view.backgroundColor = [UIColor grayColor];
    
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.leftBarButtonItem = leftBtn;
 
    //实例化拍照控制器创建图像选取控制器-----------拍照-----------
    self.picker = [[UIImagePickerController alloc]init];
    self.picker.allowsEditing = YES;
    self.picker.delegate = self;
    
    //保存路径
    self.documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    //调取用户信息
    self.bmobUtil = [BMOBUtil getInstance];
    WTUserModel *u = [self.bmobUtil getUser];
    self.userId=u.objectId;
    
    //查询数据
    self.datasource  = [NSMutableArray arrayWithCapacity:10];
    self.util = [DBUtil getInstance:u.objectId];
    self.datasource = [self.util queryPhotoById:self.userId];
    self.util.delegate = self;
    
    
    NSLog(@"本地图片数量===>%lu",(unsigned long)self.datasource.count);
    //初始化图片
    if (self.datasource.count>0) {
        NSUInteger num =self.datasource.count;
        WTPhotoModel *up = [self.datasource objectAtIndex:num-1];

        NSString *path = [NSString stringWithFormat:@"%@/Documents/%@",NSHomeDirectory(),up.pic_path];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        NSLog(@"image===%@",path);
        self.photoImage.image = image;
    }
    
    
    self.reach = [Reachability reachabilityWithHostname:@"www.bmob.cn"];
    

//登陆同步相片
    if (ReachableViaWiFi == [self.reach currentReachabilityStatus]) {
        NSLog(@"有wifi");
        [self.bmobUtil syncBmonToFMDB:self.userId];

    }

    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7 //隐藏电池栏为YES，显示为NO
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    
}

- (BOOL)prefersStatusBarHidden
{
    return YES;//隐藏电池栏为YES，显示为NO
}

//是否更新图片
-(void)isDownPhoto:(BOOL)b andImage:(NSString *)photoImage{
    [MBProgressHUD hideHUD];
    if (b) {
         NSLog(@"图片更新完成，显示图片");
        self.photoImage.image = [self loadImage:photoImage ofType:@"jpg" inDirectory:self.documentsDirectoryPath];
    }
}

-(void)notify:(BOOL)b{
    [MBProgressHUD hideHUD];
    if (b) {
        NSLog(@"控制器接收代理消息保存图片成功");
        if (ReachableViaWiFi == [self.reach currentReachabilityStatus]) {
            NSLog(@"有wifi,只上传今天的");
            NSDate *now = [NSDate date];
            NSString *today =[self.util stringFromDate:now];
            [self.bmobUtil addOrUpdateToBmob:self.userId andAddDate:today];
        }
    }else{
        NSLog(@"控制器接收代理消息保存图片失败");
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


#pragma mark - 同步执行点击方法
- (IBAction)syncAction {
    if (ReachableViaWiFi == [self.reach currentReachabilityStatus]) {
        NSLog(@"有wifi");
        [self.bmobUtil syncBmonToFMDB:self.userId];
    }else{
        [MBProgressHUD showError:@"请在wifi下同步"];
    }
}
*/

#pragma mark - 拍照按钮点击方法
- (IBAction)takeAction:(id)sender {
    UIAlertController *takeAlert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *photosAlbum = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //照片库模式。图像选取控制器以该模式显示时会浏览系统照片库的根目录。
        self.picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentViewController:self.picker animated:YES completion:nil];
        
    }];
    
    UIAlertAction *cameraBtn = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //判断是否有摄像头
        BOOL isCamera = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
        if (!isCamera) {
            NSLog(@"没有摄像头");
            return ;
        }
        //相机模式，图像选取控制器以该模式显示时可以进行拍照或摄像。
        self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:self.picker animated:YES completion:nil];
        
    }];
    [takeAlert addAction:photosAlbum];
    [takeAlert addAction:cameraBtn];
    [takeAlert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:takeAlert animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate 代理方法：拍照完成调用该
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    //获取媒体类型
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        //获取照片的原图
        UIImage *original = [info objectForKey:UIImagePickerControllerOriginalImage];

        //等比高度改为2208
        CGSize imageSize = original.size;
        CGFloat targetWidth = (imageSize.width/imageSize.height)*2208;
        UIImage* original1 = [self imageWithImageSimple:original scaledToSize:CGSizeMake(targetWidth, 2208)];
        
        //保存原图到媒体库中
        UIImageWriteToSavedPhotosAlbum(original, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);

        //文件名字
        NSDate *date = [NSDate date];
        NSDateFormatter *fmt = [[NSDateFormatter alloc]init];
        fmt.dateFormat = @"yyyyMMdd";
        NSString *dateString = [fmt stringFromDate:date];
        NSString *dateString2 = [dateString stringByAppendingString:self.userId];
        NSString *fileName =[NSString stringWithFormat:@"%@.jpg",dateString2];
        NSLog(@"图片名字:%@",fileName);
        
        //添加水印
        UIImage* original2 = [self addWatermarkInImage:original1 WithText:[self.util stringFromDate:date]];
        
        //保存到文件夹
        [self saveImage:original2 withFileName:dateString2 ofType:@"jpg" inDirectory:self.documentsDirectoryPath];

        //保存到本地数据库
        NSString *updatedAt =[self.util stringFromDateAll:[NSDate date]];
        NSLog(@"当前更新时间updatedAt:%@",updatedAt);
        WTPhotoModel *p = [[WTPhotoModel alloc]init];
        p.userID = self.userId;
        p.addDate = [self.util stringFromDate:date];
        p.updatedAtNew = updatedAt;
        p.pic_path = fileName;
        
        [self.util pickerAddUserPhoto:p];
        
        //视图中显示图片
        self.photoImage.image  = original2;
        
    }
    //关闭当前拍照界面
    [self.picker dismissViewControllerAnimated:YES completion:NULL];
    
}

//等比率缩放
-(UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
                            
}


//添加水印
-(UIImage *)addWatermarkInImage:(UIImage *)image WithText:(NSString *)string {
    NSLog(@"添加水印");
    //开启一个图形上下文
    UIGraphicsBeginImageContext(image.size);
    
    //绘制上下文：1-绘制图片
    [image drawAtPoint:CGPointZero];
    
    //绘制上下文：2-添加文字到上下文
    NSDictionary *dict = @{
                           NSFontAttributeName:[UIFont fontWithName:@"Helvetica Bold" size:45.0],
                           NSForegroundColorAttributeName:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0]
                           };
    [string drawInRect:CGRectMake(image.size.width*3/4-50, image.size.height*1/30, image.size.width-80, 80) withAttributes:dict];
    
    //从图形上下文中获取合成的图片
    UIImage * watermarkImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //关闭上下文
    UIGraphicsEndImageContext();
    return watermarkImage;
}

//裁剪图片
- (UIImage *)cutImage:(UIImage*)image
{
    //压缩图片
    CGSize newSize;
    CGImageRef imageRef = nil;
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat viewWidth = size.width;
    CGFloat viewHeight = size.height;

    if ((image.size.width / image.size.height) < (viewWidth / viewHeight)) {
        newSize.width = image.size.width;
        newSize.height = image.size.width * viewHeight / viewWidth;
        
        imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0, fabs(image.size.height - newSize.height) / 2, newSize.width, newSize.height));
        
    } else {
        newSize.height = image.size.height;
        newSize.width = image.size.height * viewWidth / viewHeight;
        
        imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(fabs(image.size.width - newSize.width) / 2, 0, newSize.width, newSize.height));
        
    }
    
    return [UIImage imageWithCGImage:imageRef];
}

//将所下载的图片保存到本地
-(void) saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    if ([[extension lowercaseString] isEqualToString:@"png"]) {
        [UIImagePNGRepresentation(image) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"png"]] options:NSAtomicWrite error:nil];
    } else if ([[extension lowercaseString] isEqualToString:@"jpg"] || [[extension lowercaseString] isEqualToString:@"jpeg"]) {
        [UIImageJPEGRepresentation(image, 0.8f) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]] options:NSAtomicWrite error:nil];
    } else {
        //ALog(@"Image Save Failed\\nExtension: (%@) is not recognized, use (PNG/JPG)", extension);
        NSLog(@"文件后缀不认识");
    }
}

//读取本地保存的图片
-(UIImage *) loadImage:(NSString *)fileName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    UIImage * result = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.%@", directoryPath, fileName, extension]];
    
    return result;
}

- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo{
    if (!error) {
        NSLog(@"图片保存本地相册成功");
    }else{
        NSLog(@"图片保存本地相册成功%@", error);
    }
}

#pragma mark - 缩放图片
-(UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize{
    
    //创建图片上下文
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    //关闭上下文
    UIGraphicsEndImageContext();
    return newImage;
}



#pragma mark - 播放动画
- (IBAction)playBtnAction:(id)sender {

    //查询数据
    self.datasource = [self.util queryPhotoById:self.userId];
    NSLog(@"本地数据库数量%lu",(unsigned long)self.datasource.count);
    
    if (self.datasource.count == 0) {
        [MBProgressHUD showError:@"没靓照，更新或拍一张吧"];
    }else{
        self.playBtn.hidden  = YES;
        self.userBtn.hidden  = YES;
        self.pickerBtn.hidden  = YES;
//        self.syncBtn.hidden = YES;
        self.friendBtn.hidden = YES;
        //判断重复点击播放
        if (self.photoImage.isAnimating) return;
        
        NSMutableArray *tempArrayM = [NSMutableArray array];
        for (NSString *string in self.datasource) {
            NSUInteger idx = [self.datasource indexOfObject:string];
            WTPhotoModel *up = [self.datasource objectAtIndex:idx];
            NSString *path = [NSString stringWithFormat:@"%@/Documents/%@",NSHomeDirectory(),up.pic_path];
            NSLog(@"idx--->%lu",(unsigned long)idx);
            
            //self.navigationItem.title = [NSString stringWithFormat:@"%lu",(unsigned long)idx];
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            //UIImage *image = [UIImage imageWithData:up.pic_path];
            [tempArrayM addObject:image];
        }
        
        self.photoImage.animationImages = tempArrayM;
        //动画播放速度及次数
        self.photoImage.animationDuration = self.photoImage.animationImages.count * 0.2;
        self.photoImage.animationRepeatCount = 1;
        
        //开始播放
        [self.photoImage startAnimating];
        
        //动画播放完毕以后，清空animationImages
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.photoImage.animationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.photoImage.animationImages = nil;
            self.playBtn.hidden  = NO;
            self.userBtn.hidden  = NO;
            self.pickerBtn.hidden  = NO;
//            self.syncBtn.hidden = NO;
            self.friendBtn.hidden = NO;
        });
    }
}



@end
