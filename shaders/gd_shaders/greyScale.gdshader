shader_type spatial;
render_mode unshaded, depth_draw_never, cull_disabled;

uniform sampler2D screen_texture : hint_screen_texture;

void vertex() {
	//POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec3 col = texture(screen_texture, uv).rgb;

	float grey = dot(col, vec3(0.299, 0.587, 0.114));
	ALBEDO = vec3(grey);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
