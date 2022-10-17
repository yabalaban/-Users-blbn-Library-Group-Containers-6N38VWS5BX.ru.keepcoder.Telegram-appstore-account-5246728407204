//
//  GameOfLife.metal
//  conway-game-of-life
//
//  Created by Alexander Balaban on 16/10/2022.
//

#include <metal_stdlib>
#import "../Common.h"

using namespace metal;

uint left(uint i, uint width) {
    uint extra = i % width == 0 ? width : 0;
    return i - 1 + extra;
}

uint right(uint i, uint width) {
    uint extra = i % width == width - 1 ? -width : 0;
    return i + 1 + extra;
}

uint top(uint i, uint width, uint count) {
    uint extra = i < width ? count : 0;
    return i - width + extra;
}

uint bottom(uint i, uint width, uint count) {
    uint extra = i >= count - width ? -count : 0;
    return i + width + extra;
}

uint index(packed_uint2 p, uint width) {
    return p.y * width + p.x;
}

uint move(uint i, int2 dxdy, uint width, uint count) {
    uint res = i;
    int dx = abs(dxdy.x);
    int dy = abs(dxdy.y);
    if (dxdy.x < 0) {
        while (dx > 0) {
            res = left(res, width);
            dx -= 1;
        }
    } else {
        while (dx > 0) {
            res = right(res, width);
            dx -= 1;
        }
    }
    if (dxdy.y < 0) {
        
        while (dy > 0) {
            res = bottom(res, width, count);
            dy -= 1;
        }
    } else {
        while (dy > 0) {
            res = top(res, width, count);
            dy -= 1;
        }
    }
    return res;
}

kernel void game_of_life_tick(device bool *current [[buffer(0)]],
                              device bool *next [[buffer(1)]],
                              constant Params &params [[buffer(2)]],
                              uint position [[thread_position_in_grid]]) {
    uint total = 0;
    uint width = params.gridWidth;
    uint count = params.gridWidth * params.gridHeight;
    total += current[left(position, width)];
    total += current[right(position, width)];
    total += current[top(position, width, count)];
    total += current[top(left(position, width), width, count)];
    total += current[top(right(position, width), width, count)];
    total += current[bottom(position, width, count)];
    total += current[bottom(left(position, width), width, count)];
    total += current[bottom(right(position, width), width, count)];
    
    if (current[position] && total >= 2 && total <= 3) {
        next[position] = true;
    } else if (!current[position] && total == 3) {
        next[position] = true;
    } else {
        next[position] = false;
    }
}

kernel void game_of_life_copy(device bool *current [[buffer(0)]],
                              device bool *next [[buffer(1)]],
                              uint position [[thread_position_in_grid]]) {
    current[position] = next[position];
}

kernel void game_of_life_spawn(device bool *grid [[buffer(0)]],
                               constant GridPatternParams &pattern_params [[buffer(1)]],
                               constant int2 *pattern_points [[buffer(2)]],
                               constant Params &params [[buffer(3)]]) {
    uint idx = index(pattern_params.origin, params.gridWidth);
    uint width = params.gridWidth;
    uint count = width * params.gridHeight;
    for (uint i = 0; i < pattern_params.size; ++i) {
        grid[move(idx, pattern_points[i], width, count)] = true;
    }
}
