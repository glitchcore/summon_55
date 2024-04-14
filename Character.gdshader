shader_type canvas_item;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898,78.233))) * 43758.5453123); 
}

float _noise(vec2 x) {
    vec2 p = floor(x);
    vec2 f = fract(x);
    f = f * f * (3.0 - 2.0 * f);
    vec2 a = vec2(1.0, 0.0);
    return mix(mix(hash(p + a.yy), hash(p + a.xy), f.x), mix(hash(p + a.yx), hash(p + a.xx), f.x), f.y);
}

const vec3 RED = vec3(1., 0., 0.);
const vec3 GREEN = vec3(0., 1., 0.);
const vec3 WHITE = vec3(1.);
const vec3 BG = vec3(0.9);

vec4 fire(vec2 uv, float t, vec3 texture) {
    vec4 res;
    
    float cloud_mask = texture.b; // clamp(1. - length(uv * 2.) + 0.2, 0., 1.);
	
	float cloud =
	    _noise(vec2(length(uv) * 6. + vec2(-t * 2., 0.))) * 
	    _noise(vec2(uv * 3. + vec2(0, -t * 2.)));
	float hard_cloud = clamp(cloud * 2., 0., 1.);
	float soft_cloud = clamp(cloud * 1., 0., 1.) * cloud_mask;
	
	float inner = texture.g > 0.7 ? 1. : 0.;
	float outer = texture.r < 0.7 ? 1. : 0.;
	
	float contour = texture.g * (1. - inner);
	
	res.a = max(outer, soft_cloud);
	
	if(outer > 0.) {
	    res.rgb = max(vec3(inner), hard_cloud * GREEN);
	} else {
	    res.rgb = GREEN;
	}
	
	// res.a = 1.;
	// res.rgb = cloud * RED;
	
	return res;
}

uniform vec2 frame_size;
uniform vec2 sprite_sheet_size;
uniform float time_seed;

void fragment() {
	vec2 current_point = sprite_sheet_size * UV;
	float row = floor(current_point.y / frame_size.y);
	float column = floor(current_point.x / frame_size.x);
	vec2 max_point = (frame_size * vec2(column, row)) + frame_size;
	vec2 new_uv = 1.0 - (max_point - current_point) / frame_size;
	
	vec3 man = texture(TEXTURE, UV).rgb;
	
	vec4 res = fire(new_uv, TIME + time_seed, man);
	
	COLOR.rgb = res.rgb;
	COLOR.a = res.a;
}
