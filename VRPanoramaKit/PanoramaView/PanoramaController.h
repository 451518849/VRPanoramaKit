//
//  PanoramaController.h
//  VRPanoramaKit
//
//  Created by 小发工作室 on 2017/9/21.
//  Copyright © 2017年 小发工作室. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <CoreMotion/CoreMotion.h>

@interface PanoramaController : GLKViewController

@property (nonatomic, copy  ) NSString        *imageName;

@property (nonatomic, copy  ) NSString        *imageNameType;

@property (nonatomic, strong) CMMotionManager *motionManager;

@property (nonatomic, strong) GLKView         *panoramaView;


/**
 初始化全景控制器

 @param imageName 全景图名字
 @param type 全景图类型，默认是jpg
 @return PanoramaController
 */
- (instancetype)initWithImageName:(NSString *)imageName type:(NSString *)type;


/**
 启动全景图
 */
- (void)startPanoramViewMotion;


/**
 关闭全景图
 */
- (void)stopPanoramViewMotion;

@end
