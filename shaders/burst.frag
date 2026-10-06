#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time;
    float spin;
    float aspect;
    float centerX;
    float centerY;
    float res;
    float pulse;
};

const float PI = 3.14159265;
const vec3 cRed = vec3(0.86, 0.03, 0.09);
const vec3 cDeep = vec3(0.52, 0.0, 0.04);
const vec3 cBlack = vec3(0.02, 0.0, 0.01);

void main() {
    vec2 p = (qt_TexCoord0 - vec2(centerX, centerY)) * vec2(aspect, 1.0);
    float r = length(p);
    float a = atan(p.y, p.x) + time * 0.045 + spin;
    float rays = 14.0;
    float tri = abs(fract(a / (2.0 * PI) * rays) - 0.5) * 2.0;
    float aa = rays / (PI * max(r, 0.02) * res);
    float ray = smoothstep(0.5 - aa, 0.5 + aa, tri);
    float thin = 1.0 - smoothstep(0.06 - aa, 0.06 + aa, abs(fract(a / (2.0 * PI) * rays * 0.5 + 0.25) - 0.5) * 2.0);

    vec3 col = mix(cDeep, cRed, ray);
    col = mix(col, cBlack, thin * 0.85 * smoothstep(0.08, 0.3, r));
    col = mix(col, cRed * 1.15, (1.0 - smoothstep(0.0, 0.28 + pulse * 0.05, r)) * 0.55);

    float ang = 0.5236;
    mat2 rot = mat2(cos(ang), -sin(ang), sin(ang), cos(ang));
    vec2 g = rot * (qt_TexCoord0 * vec2(aspect, 1.0) * res / 9.0);
    g.x += time * 0.35;
    vec2 cell = fract(g) - 0.5;
    float wave = 0.5 + 0.5 * sin(r * 9.0 - time * 1.6);
    float radius = clamp((r - 0.26) * 0.62 + wave * 0.07, 0.0, 0.5);
    float dotEdge = 1.4 / 9.0;
    float dotMask = 1.0 - smoothstep(radius - dotEdge, radius + dotEdge, length(cell));
    col = mix(col, cBlack, dotMask * step(0.02, radius));

    col *= 1.0 - 0.45 * smoothstep(0.6, 1.3, r);
    fragColor = vec4(col, 1.0) * qt_Opacity;
}
