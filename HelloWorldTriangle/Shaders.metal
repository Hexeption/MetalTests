//
//  Shaders.metal
//  HelloWorldTriangle
//
//  Created by Keir Davis on 28/09/2023.
//

#include <metal_stdlib>
using namespace metal;

#include "definitions.h"

float3 applyDirectionalLight(float3 normal, DirectionalLight light, float3 baseColor, float3 fragCamera);
float3 applySpotLight(float3 position, float3 normal, Spotlight light, float3 baseColor, float3 fragCamera);
float3 applyPointLight(float3 position, float3 normal, Pointlight light, float3 baseColor, float3 fragCamera);

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
    
    //directions
    float3 fragCamera = normalize(input.cameraPos - input.fragPos);

    //ambient
    float3 color = 0.2 * baseColor;
    
    //sun
    color += applyDirectionalLight(input.normal, sun, baseColor, fragCamera);
    
    //spotlight
    color += applySpotLight(input.fragPos, input.normal, spotlight, baseColor, fragCamera);
    
    for (uint i = 0; i < fragUBO.lightCount; i++) {
        color += applyPointLight(input.fragPos, input.normal, pointLights[i], baseColor, fragCamera);
    }
    
    return float4(color, 1.0);
};

float3 applyDirectionalLight(float3 normal, DirectionalLight light, float3 baseColor, float3 fragCamera) {
    
    float3 result = float3(0.0);
    
    float3 halfVec = normalize(-light.forwards + fragCamera);
    
    //diffuse
    float lightAmmount = max(0.0, dot(normal, -light.forwards));
    result += lightAmmount * baseColor * light.color;
    
    //specular
    lightAmmount = pow(max(0.0, dot(normal, halfVec)), 64);
    result += lightAmmount * baseColor * light.color;
    
    return result;
}

float3 applySpotLight(float3 position, float3 normal, Spotlight light, float3 baseColor, float3 fragCamera) {
    
    float3 result = float3(0.0);
    
    //directions
    float3 fragLight = normalize(light.position - position);
    float3 halfVec = normalize(fragLight + fragCamera);
    
    //diffuse
    float lightAmmount = max(0.0, dot(normal, fragLight)) * pow(max(0.0, dot(fragLight, light.forwards)), 16);
    result += lightAmmount * baseColor * light.color;
    
    //specular
    lightAmmount = pow(max(0.0, dot(normal, halfVec)), 64) * pow(max(0.0, dot(fragLight, light.forwards)), 16);
    result += lightAmmount * baseColor * light.color;
    
    return result;
}

float3 applyPointLight(float3 position, float3 normal, Pointlight light, float3 baseColor, float3 fragCamera) {
    float3 result = float3(0.0);
    
    //directions
    float3 fragLight = normalize(light.position - position);
    float3 halfVec = normalize(fragLight + fragCamera);
    
    //diffuse
    float lightAmount = max(0.0, dot(normal, fragLight));
    result += lightAmount * baseColor * light.color;
    
    //specular
    lightAmount = pow(max(0.0, dot(normal, halfVec)), 64);
    result += lightAmount * baseColor * light.color;
    
    return result;
}


