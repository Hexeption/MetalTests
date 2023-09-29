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
    float3 normal [[attribute(2)]];
};

struct Fragment {
    float4 position [[position]];
    float2 textureCoord;
    float3 normal;
    float3 cameraPos;
    float3 fragPos;
};

vertex Fragment vertexShader(
    const VertexIn vertex_in [[stage_in]],
    constant matrix_float4x4 &model [[buffer(1)]],
    constant CameraParameters &camera [[buffer(2)]]
) {
    
    // Ignore this stupid cast hack.
    matrix_float3x3 diminished_model;
    diminished_model[0][0] = model[0][0];
    diminished_model[0][1] = model[0][1];
    diminished_model[0][2] = model[0][2];
    diminished_model[1][0] = model[1][0];
    diminished_model[1][1] = model[1][1];
    diminished_model[1][2] = model[1][2];
    diminished_model[2][0] = model[2][0];
    diminished_model[2][1] = model[2][1];
    diminished_model[2][2] = model[2][2];
    
    Fragment output;
    output.position = camera.projection * camera.view * model * vertex_in.position;
    output.textureCoord = vertex_in.textureCoord;
    output.normal = diminished_model * vertex_in.normal;
    output.cameraPos = camera.position;
    output.fragPos = float3(model * vertex_in.position);
    
    return output;
}; 

fragment float4 fragmentShader(
    Fragment input [[stage_in]],
    texture2d<float> objectTexture [[texture(0)]],
    sampler samplerObject [[sampler(0)]],
    constant DirectionalLight &sun [[buffer(0)]],
    constant Spotlight &spotlight [[buffer(1)]],
    constant Pointlight *pointLights [[buffer(2)]],
    constant FragmentData &fragUBO [[buffer(3)]]
) {
    float3 baseColor = float3(objectTexture.sample(samplerObject, input.textureCoord));
    
    float3 color = 0.2 * baseColor;
    
    //directions
    float3 fragCamera = normalize(input.cameraPos - input.fragPos);
    float3 halfVec = normalize(-sun.forwards + fragCamera);
    
    //diffuse
    float lightAmmount = max(0.0, dot(input.normal, -sun.forwards));
    color += lightAmmount * baseColor * sun.color;
    
    //specular
    lightAmmount = pow(max(0.0, dot(input.normal, halfVec)), 64);
    color += lightAmmount * baseColor * sun.color;
    
    //directions
    float3 fragLight = normalize(spotlight.position - input.fragPos);
    halfVec = normalize(fragLight + fragCamera);
    
    //diffuse
    lightAmmount = max(0.0, dot(input.normal, fragLight)) * pow(max(0.0, dot(spotlight.forwards, -fragLight)), 32);
    color += lightAmmount * baseColor * spotlight.color;
    
    //specular
    lightAmmount = pow(max(0.0, dot(input.normal, halfVec)), 64) * pow(max(0.0, dot(spotlight.forwards, -fragLight)), 32);
    color += lightAmmount * baseColor * spotlight.color;
    
    for (uint i = 0; i < fragUBO.lightCount; i++) {
        //directions
        float3 fragLight = normalize(pointLights[i].position - input.fragPos);
        halfVec = normalize(fragLight + fragCamera);
        
        //diffuse
        lightAmmount = max(0.0, dot(input.normal, fragLight));
        color += lightAmmount * baseColor * pointLights[i].color;
        
        //specular
        lightAmmount = pow(max(0.0, dot(input.normal, halfVec)), 64);
        color += lightAmmount * baseColor * pointLights[i].color;
    }
    
    
    return float4(color, 1.0);
};


