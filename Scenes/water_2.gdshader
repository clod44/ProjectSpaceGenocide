shader_type canvas_item;

uniform sampler2D refraction_map : repeat_enable;
uniform vec2 refraction_stretch = vec2(1.0, 1.0);

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;


void fragment() {
    vec4 color = texture(SCREEN_TEXTURE, UV);
    COLOR = color;
}

void vertex(){ 
	vec2 normalized_uv = SCREEN_UV / refraction_stretch; // Normalize the UV coordinates based on the texture size
	float refraction_offset = texture(refraction_map, normalized_uv).r;
	
}

