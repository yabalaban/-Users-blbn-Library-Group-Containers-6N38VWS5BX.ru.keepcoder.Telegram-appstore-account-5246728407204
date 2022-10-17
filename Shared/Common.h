//
//  Common.h
//  conway-game-of-life
//
//  Created by Alexander Balaban on 13/10/2022.
//

#ifndef Common_h
#define Common_h

#import <simd/simd.h>

typedef struct {
    float width;
    float height;
    int32_t gridWidth;
    int32_t gridHeight;
} Params;

typedef struct {
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
} Uniforms;

typedef struct {
    uint state;
} Cell;

typedef struct {
    packed_uint2 origin;
    uint size;
} GridPatternParams;

#endif /* Common_h */
