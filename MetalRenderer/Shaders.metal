//
//  Shaders.metal
//  MetalRenderer
//
//  Created by Triumph on 03/10/2023.
//

#include <metal_stdlib>
using namespace metal;

#import "Common.h"

constant float3 color[6] = { // array of colors of each vertices
    float3(1,0,0),
    float3(0,1,0),
    float3(0,0,1),
    float3(0,0,1),
    float3(0,1,0),
    float3(1,0,1)
};


struct VertexIn {
    float4 position [[attribute(0)]]; //the vertex descriptor allows us to use a float4 instead of float3
    //float3 color [[attribute(1)]]; not needed when importing model with Model IO
};

struct VertexOut {
    float4 position [[position]];
    float point_size [[point_size]];
    float3 color;
};
/*
vertex VertexOut vertex_main(device const float4 *positionBuffer [[buffer(0)]],
                             device const float3 *colorBuffer [[buffer(1)]],
                             constant float &timer [[buffer(2)]],
                             uint vertexId [[vertex_id]]) { //vertex_id -> which vertex is currently processing
*/
vertex VertexOut vertex_main(VertexIn vertexBuffer [[stage_in]],
                             constant uint &colorIndex [[buffer(11)]], 
                             constant Uniforms &uniforms[[buffer(21)]]) { //using the stage_in, all necessary information comes from the VertexDescriptor

    VertexOut out {
        .position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * vertexBuffer.position,
        .color = color[colorIndex]
        //.color = float3(0, 0 , 1) // blue now, later we will read the color from the material file
    };
    //out.position.y -= 0.5;
    return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]]) { //[[stage_in]] allows to pass the vertex as parameter
    return float4(in.color, 1); // rgba
}


