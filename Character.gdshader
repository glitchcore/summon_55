shader_type canvas_item;

uniform vec2 frame_size;
uniform vec2 sprite_sheet_size;
   
const vec3 RED = vec3(1., 0., 0.);
const vec3 GREEN = vec3(0., 1., 0.);

void fragment() {
	vec2 current_point = sprite_sheet_size * UV;
	float row = floor(current_point.y / frame_size.y);
	float column = floor(current_point.x / frame_size.x);
	vec2 max_point = (frame_size * vec2(column, row)) + frame_size;
	vec2 new_uv = 1.0 - (max_point - current_point) / frame_size;
	
	float man = texture(TEXTURE, UV).r;
	vec3 color = vec3(0.);
	
	float bg = 1. - clamp(length(new_uv - vec2(0.5)) * 3., 0., 1.);
	
	float cloud = clamp(bg + 0.2, 0., 1.);
	
	COLOR.rgb = man > 0. ? vec3(1.) : GREEN;
	COLOR.a = man > 0. ? 1. : bg;
}
