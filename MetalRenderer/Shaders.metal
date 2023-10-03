//
//  Shaders.metal
//  MetalRenderer
//
//  Created by Triumph on 03/10/2023.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float point_size [[point_size]];
    float3 color;
};

vertex VertexOut vertex_main() {

    VertexOut out {
        .position = float4(0,0,0,1), //x,y,z,w centre of the screen
        .point_size = 60.0,
        .color = float3(1, 1, 0)
    };
    return out;
}

fragment float4 fragment_main() {
    return float4(0, 0, 1, 1); // rgba
}


