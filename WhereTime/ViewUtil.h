//
//  ViewUtil.h
//  WT
//
//  Created by Mac on 16/7/2.
//  Copyright © 2016年 qiezi0301. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ViewUtil : NSObject

+(UIButton *)buttonWithTitle:(NSString *)title
                       image:(UIImage *)image
            highlightedImage:(UIImage *)highlightedImage;


+ (UIImage *)imageByScalingToSize:(CGSize)targetSize
                      sourceImage:(UIImage *)sourceImage;

+ (UIImage *)resizeImageWithWidth:(CGFloat)width
                      sourceImage:(UIImage *)sourceImage;

@end
