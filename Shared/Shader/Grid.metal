//
//  Shader.metal
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

vertex float4 vertex_main_grid(const VertexIn in [[stage_in]]) {
    return in.position;
}

fragment float4 fragment_main_grid() {
    return float4(0.52, 0.24, 0.25, 0.0);
}
