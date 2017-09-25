//
//  PanoramaUtil.h
//  VRPanoramaKit
//
//  Created by 小发工作室 on 2017/9/22.
//  Copyright © 2017年 小发工作室. All rights reserved.
//

#ifndef PanoramaUtil_h
#define PanoramaUtil_h

#include <stdio.h>

/**
 根据numSlices和radius的大小取索引，顶点，纹理的值
 
 @param numSlices 球面切面数量
 @param radius 半径
 @param vertices 3维顶点坐标
 @param texCoords 纹理
 @param indices 索引
 @param vertices_count 3维顶点坐标数量
 @return 索引数量
 */
int esGenSphere(int numSlices,
                float radius,
                float **vertices,
                float **texCoords,
                uint16_t **indices,
                int *vertices_count);

#endif /* PanoramaUtil_h */
