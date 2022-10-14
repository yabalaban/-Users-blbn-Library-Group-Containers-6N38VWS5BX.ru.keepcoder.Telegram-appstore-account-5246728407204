//
//  Foreground.metal
//  conway-game-of-life
//
//  Created by Alexander Balaban on 13/10/2022.
//

#include <metal_stdlib>
#import "../Common.h"

using namespace metal;

struct VertexIn {
    float4 position [[attribute(0)]];
};

struct FragmentIn {
    float4 position [[position]];
};

vertex FragmentIn vertex_main_foreground(const VertexIn in [[stage_in]]) {
    return (FragmentIn) {
        .position = in.position
    };
}

fragment float4 fragment_main_foreground(const FragmentIn in [[stage_in]],
                                         constant Params &params [[buffer(0)]],
                                         constant bool *cells [[buffer(1)]]) {
    float x_step = 1.0 / params.gridHeight;
    float y_step = 1.0 / params.gridWidth;
    float x = in.position.x / (2 * params.width);
    float y = in.position.y / (2 * params.height);
    int i = trunc(x / x_step);
    int j = trunc(y / y_step);
    if (cells[j * params.gridWidth + i]) {
        return float4(float3(0.87), 0.1);
    } else {
        return float4(float3(0.07), 0.1);
    }
}
