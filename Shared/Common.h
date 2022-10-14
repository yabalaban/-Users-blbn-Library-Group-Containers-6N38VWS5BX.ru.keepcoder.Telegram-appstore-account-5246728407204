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
    uint state;
} Cell;

#endif /* Common_h */
