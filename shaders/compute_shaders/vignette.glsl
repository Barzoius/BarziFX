#[compute]
#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(set = 0, binding = 0, std430) readonly buffer Params {
    vec2 raster_size;
    vec2 padding;
} params;

layout(set = 0, binding = 1, std430) readonly buffer Params2 {
    float radius;
    float intensity;
    float softness;
    float inverted; // 0.0 or 1.0
} params2;

layout(rgba16f, set = 0, binding = 2) uniform image2D color_image;

void main()
{
    ivec2 uv = ivec2(gl_GlobalInvocationID.xy);

    vec2 size = params.raster_size;

    if (uv.x >= int(size.x) || uv.y >= int(size.y))
        return;

    vec2 uv_normalized = vec2(uv) / size;
    vec2 center = uv_normalized * 2.0 - 1.0;

    float dist = length(center);

    // Ensure correct ordering for smoothstep (critical fix)
    float r0 = params2.radius - params2.softness;
    float r1 = params2.radius;

    float mask = smoothstep(r0, r1, dist);

    // HARD boolean inversion (no float logic)
    if (params2.inverted > 0.5)
    {
        mask = 1.0 - mask;
    }

    float vignette = mix(1.0, 1.0 - params2.intensity, mask);

    vec4 color = imageLoad(color_image, uv);
    color.rgb *= vignette;

    imageStore(color_image, uv, color);
}