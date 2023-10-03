//
//  Shaders.metal
//  MetalRenderer
//
//  Created by Triumph on 03/10/2023.
//

#include <metal_stdlib>
using namespace metal;

/*
constant float3 color[6] = { // array of colors of each vertices
    float3(1,0,0),
    float3(0,1,0),
    float3(0,0,1),
    float3(0,0,1),
    float3(0,1,0),
    float3(1,0,1)
};
 */

struct VertexOut {
    float4 position [[position]];
    float point_size [[point_size]];
    float3 color;
};

vertex VertexOut vertex_main(device const float4 *positionBuffer [[buffer(0)]],
                             device const float3 *colorBuffer [[buffer(1)]],
                             uint vertexId [[vertex_id]]) { //vertex_id -> which vertex is currently processing

    VertexOut out {
        .position = positionBuffer[vertexId],
        .point_size = 60.0,
        .color = colorBuffer[vertexId]
    };
    return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]]) { //[[stage_in]] allows to pass the vertex as parameter
    return float4(in.color, 1); // rgba
}


