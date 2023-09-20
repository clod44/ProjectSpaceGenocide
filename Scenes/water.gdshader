shader_type canvas_item;

uniform sampler2D refraction_map : repeat_enable;

uniform vec2 refraction_stretch = vec2(1.0, 1.0);
uniform float refraction_strength : hint_range(0.0, 0.1) = 0.02;

uniform vec4 water_tint : source_color = vec4(0.2, 0.6, 1.0, 0.1);
uniform float speed : hint_range(0.0, 1.0) = 0.1;

uniform sampler2D foam_texture : repeat_enable;
uniform float foam_speed = 0.1;
uniform float foam_thickness = 0.01;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

varying vec2 globalposition;
void vertex(){
	globalposition = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}


void fragment()
{
	vec2 uv = globalposition / 128.0;
	
	vec2 refraction_offset = texture(
		refraction_map, 
		vec2(
			mod(uv.x * refraction_stretch.x + TIME * speed, 1.0), 
			mod(uv.y * refraction_stretch.y + TIME * speed, 1.0))).xy;
	// Set values between -0.5 and 0.5 (instead of 0 and 1). Otherwise the reflection will move whith increased refraction_strength
	refraction_offset -= 0.5; 
	
	// Get the screen texture and distort it
	vec4 refraction = texture(SCREEN_TEXTURE, SCREEN_UV - refraction_offset * refraction_strength);
	
	vec4 color = vec4(1.0);
	
	color.rgb = mix(refraction.rgb, water_tint.rgb, water_tint.a);
	
	
	
	// Calculate distance to the closest edge
	/*
	float min_distance_to_edge = min(
	    min(UV.x, 1.0 - UV.x),
	    min(UV.y, 1.0 - UV.y)
	);
	*/
	
	// Sample the foam texture to get foam thickness
	float foam_density = texture(foam_texture, UV+vec2(TIME, TIME)*foam_speed).r;
	foam_density *= foam_density;
	float min_distance_to_edge = UV.y - foam_thickness;
	// Create a bright stripe at edges based on distance
	float edge_factor = 1.0 - clamp(smoothstep(0.0, 0.05, min_distance_to_edge), 0.0, 1.0); // Adjust the threshold for the width of the stripe
	color += edge_factor * vec4(1.0, 1.0, 1.0, 0.1) * foam_density;

	COLOR = color;
}