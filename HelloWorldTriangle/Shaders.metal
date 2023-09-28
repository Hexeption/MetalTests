//
//  Shaders.metal
//  HelloWorldTriangle
//
//  Created by Keir Davis on 28/09/2023.
//

#include <metal_stdlib>
using namespace metal;

#include "definitions.h"

struct VertexIn {
    float4 position [[attribute(0)]];
    float2 textureCoord [[attribute(1)]];
};

struct Fragment {
    float4 position [[position]];
    float2 textureCoord;
};

vertex Fragment vertexShader(
    const VertexIn vertex_in [[stage_in]],
    constant matrix_float4x4 &model [[buffer(1)]],
    constant CameraParameters &camera [[buffer(2)]]
) {
    
    Fragment output;
    output.position = camera.projection * camera.view * model * vertex_in.position;
    output.textureCoord = vertex_in.textureCoord;
    
    return output;
}; 

fragment float4 fragmentShader(
    Fragment input [[stage_in]],
    texture2d<float> objectTexture [[texture(0)]],
    sampler samplerObject [[sampler(0)]]
) {
    
    return objectTexture.sample(samplerObject, input.textureCoord);
};


