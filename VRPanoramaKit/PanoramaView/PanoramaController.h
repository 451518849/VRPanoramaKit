//
//  PanoramaView.h
//  VRPanoramaKit
//
//  Created by 小发工作室 on 2017/9/21.
//  Copyright © 2017年 小发工作室. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <CoreMotion/CoreMotion.h>

@interface PanoramaView : GLKViewController

@property (nonatomic, copy  ) NSString        *imageName;

// 运动管理
@property (nonatomic, strong) CMMotionManager *motionManager;

@end
