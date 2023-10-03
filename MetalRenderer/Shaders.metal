//
//  Shaders.metal
//  MetalRenderer
//
//  Created by Triumph on 03/10/2023.
//

#include <metal_stdlib>
using namespace metal;

constant float4 position[3] = { // array of positions of each vertices
    float4(-0.5, -0.2, 0, 1),
    float4(0.2, -0.2, 0, 1),
    float4(0, 0.5, 0, 1)
};

constant float3 color[3] = { // array of colors of each vertices
    float3(1,0,0),
    float3(0,1,0),
    float3(0,0,1)
};

struct VertexOut {
    float4 position [[position]];
    float point_size [[point_size]];
    float3 color;
};

vertex VertexOut vertex_main(uint vertexId [[vertex_id]]) { //vertex_id -> which vertex is currently processing

    VertexOut out {
        .position = position[vertexId], //x,y,z,w centre of the screen
        .point_size = 60.0,
        .color = color[vertexId]
    };
    return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]]) { //[[stage_in]] allows to pass the vertex as parameter
    return float4(in.color, 1); // rgba
}


