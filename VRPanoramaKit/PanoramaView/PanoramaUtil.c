//
//  PanoramaUtil.c
//  VRPanoramaKit
//
//  Created by 小发工作室 on 2017/9/22.
//  Copyright © 2017年 小发工作室. All rights reserved.
//

#include "PanoramaUtil.h"
#include <stdlib.h>
#include <math.h>

#define ES_PI  (3.14159265f)


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
                int *vertices_count) {
    
    
    int numParallels = numSlices / 2;
    int numVertices  = (numParallels + 1) * (numSlices + 1);
    int numIndices   = numParallels * numSlices * 6;
    
    float angleStep  = (2.0f * ES_PI) / ((float) numSlices);
    
    if (vertices != NULL) {
        *vertices = malloc(sizeof(float) * 3 * numVertices);
    }
    
    if (texCoords != NULL) {
        *texCoords = malloc(sizeof(float) * 2 * numVertices);
    }
    
    if (indices != NULL) {
        *indices = malloc(sizeof(uint16_t) * numIndices);
    }
    
    for (int i = 0; i < numParallels + 1; i++) {
        for (int j = 0; j < numSlices + 1; j++) {
            int vertex = (i * (numSlices + 1) + j) * 3;
            
            if (vertices) {
                (*vertices)[vertex + 0] = radius * sinf(angleStep * (float)i) * sinf(angleStep * (float)j);
                (*vertices)[vertex + 1] = radius * cosf(angleStep * (float)i);
                (*vertices)[vertex + 2] = radius * sinf(angleStep * (float)i) * cosf(angleStep * (float)j);
            }
            
            if (texCoords) {
                int texIndex = (i * (numSlices + 1) + j) * 2;
                (*texCoords)[texIndex + 0] = (float)j / (float)numSlices;
                (*texCoords)[texIndex + 1] = 1.0f - ((float)i / (float)numParallels);
            }
        }
    }
    
    // Generate the indices
    if (indices != NULL) {
        uint16_t *indexBuf = (*indices);
        for (int i = 0; i < numParallels ; i++) {
            for (int j = 0; j < numSlices; j++) {
                *indexBuf++ = i * (numSlices + 1) + j;
                *indexBuf++ = (i + 1) * (numSlices + 1) + j;
                *indexBuf++ = (i + 1) * (numSlices + 1) + (j + 1);
                
                *indexBuf++ = i * (numSlices + 1) + j;
                *indexBuf++ = (i + 1) * (numSlices + 1) + (j + 1);
                *indexBuf++ = i * (numSlices + 1) + (j + 1);
            }
        }
    }
    
    if (vertices_count) {
        *vertices_count = numVertices;
    }
    
    return numIndices;
}
