#version 460 core

#include <flutter/runtime_effect.glsl>

//precision mediump float;

uniform vec2 size;
uniform float lut_value;
uniform sampler2D source_texture;
uniform sampler2D lut_texture;

out vec4 fragColor;

const float lut_dimension = 64.0;
const float lut_size = 512.0;

float myround(float x) {
    float z = 0.0;
    if(fract(x) >= 0.5) {
        z = ceil(x);
    } else {
        z = floor(x);
    }
    return z;
}

vec4 lut_filter(vec4 in_color, float lut_value, float dimension, float size) {
    float row = 8.0;

    float b = in_color.b * 63.0;
    float b_floor = floor(b);
    float b_ceil = ceil(b);
    float b_fract = fract(b);

    vec2 quad_1 = vec2(0.0);
    quad_1.y = floor(b_floor / row);
    quad_1.x = b_floor - (quad_1.y * row);

    vec2 quad_2 = vec2(0.0);
    quad_2.y = floor(b_ceil / row);
    quad_2.x = b_ceil - (quad_2.y * row);

    vec2 pos = vec2(1.0 / 1024.0) + (vec2(63.0 / 512.0) * in_color.rg);
    vec2 tex_pos_1 = quad_1 * 0.125 + pos;
    vec2 tex_pos_2 = quad_2 * 0.125 + pos;

    vec4 lut_color_1 = texture(lut_texture, tex_pos_1);
    vec4 lut_color_2 = texture(lut_texture, tex_pos_2);
    vec4 lut_color = mix(lut_color_1, lut_color_2, b_fract);

    return mix(in_color, vec4(lut_color.rgb, in_color.a), lut_value);
}

void main() {
    vec2 uv = FlutterFragCoord().xy / size;
    vec4 color = texture(source_texture, uv);
    fragColor = lut_filter(color, lut_value, lut_dimension, lut_size);
}
