#[compute]
#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(set = 0, binding = 0, std430) readonly buffer Params {
	vec2 raster_size;
	vec2 reserved;
} params;

layout(rgba16f, set = 0, binding = 1) uniform image2D color_image;

void main()
{
    ivec2 uv = ivec2(gl_GlobalInvocationID.xy);
    ivec2 size = ivec2(params.raster_size);

    if (uv.x >= size.x || uv.y >= size.y)
        return;

    int pixel_size = 4;
    float color_channels = 64.0;

    ivec2 block_uv = (uv / pixel_size) * pixel_size;

    
    vec4 color = imageLoad(color_image, block_uv);
    vec3 quant_color = floor(color.rgb * color_channels) / color_channels;

    imageStore(color_image, uv, vec4(quant_color.rgb, 1.0));
}