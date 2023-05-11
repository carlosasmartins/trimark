//
//  VideoPlayer.Watermarking+MetalShaders.swift
//  Trimark
//
//  Created by Carlos Martins on 10/05/2023.
//

#include <metal_stdlib>
using namespace metal;

// MARK: - Constants
constant float PI = 3.1415926535897932;

// MARK: - Customization Parameters

// Speed Parameters
constant float speed_x = 0.3;
constant float speed_y = 0.3;

// Refraction Parameters
constant float emboss = 0.20;
constant float intensity = 2.4;
constant int steps = 3;
constant float frequency = 3.0;
constant int angle = 21;

// Reflection Parameters
constant float delta = 60.;
constant float reflectionCutOff = 0.012;
constant float reflectionIntence = 200000.;

float col(float2 coord,
          float time,
          float speed) {
    float delta_theta = 2.0 * PI / float(angle);
    float col = 0.0;
    float theta = 0.0;
    for (int i = 0; i < steps; i++) {
        float2 adjc = coord;
        theta = delta_theta * float(i);
        adjc.x += cos(theta) * time * speed + time * speed_x;
        adjc.y -= sin(theta) * time * speed - time * speed_y;
        col = col + cos((adjc.x * cos(theta) - adjc.y * sin(theta)) * frequency) * intensity;
    }
    
    return cos(col);
}

kernel void computeWaterDance(texture2d<float, access::write> output [[texture(0)]],
                    texture2d<float, access::sample> input [[texture(1)]],
                    constant float &timer [[buffer(0)]],
                    constant float &speed [[buffer(1)]],
                    constant float &intensity [[buffer(2)]],
                    uint2 gid [[thread_position_in_grid]]) {
    float time = timer *  1.3;
    
    int width = output.get_width();
    int height = output.get_height();
    
    float2 p = float2(gid) / float2(width, height);
    
    p = float2(p.x, 1 - p.y);
    
    float2 c1 = p, c2 = p;
    float cc1 = col(c1, time, speed);
    
    c2.x += width / delta;
    float dx = emboss * (cc1 - col(c2, time, speed)) / delta;
    
    c2.x = p.x;
    c2.y += height / delta;
    float dy = emboss * (cc1 - col(c2, time, speed)) / delta;
    
    c1.x += dx * 2.;
    c1.y = -(c1.y + dy * 2.);
    
    float alpha = 1. + dx * dy * intensity;
    
    float ddx = dx - reflectionCutOff;
    float ddy = dy - reflectionCutOff;
    if (ddx > 0. && ddy > 0.)
        alpha = pow(alpha, ddx * ddy * reflectionIntence);
    
    constexpr sampler textureSampler(coord::normalized,
                                     address::repeat,
                                     min_filter::linear,
                                     mag_filter::linear,
                                     mip_filter::linear);
    
    float4 color = input.sample(textureSampler, c1).rgba;
    output.write(color * (alpha), gid);
}
