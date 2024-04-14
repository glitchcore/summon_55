shader_type canvas_item;

/* discontinuous pseudorandom uniformly distributed in [-0.5, +0.5]^3 */
vec3 random3(vec3 c) {
	float j = 4096.0*sin(dot(c,vec3(17.0, 59.4, 15.0)));
	vec3 r;
	r.z = fract(512.0*j);
	j *= .125;
	r.x = fract(512.0*j);
	j *= .125;
	r.y = fract(512.0*j);
	return r-0.5;
}

/* skew constants for 3d simplex functions */
const float F3 =  0.3333333;
const float G3 =  0.1666667;

/* 3d simplex noise */
float _noise(vec3 p) {
	 /* 1. find current tetrahedron T and it's four vertices */
	 /* s, s+i1, s+i2, s+1.0 - absolute skewed (integer) coordinates of T vertices */
	 /* x, x1, x2, x3 - unskewed coordinates of p relative to each of T vertices*/
	 
	 /* calculate s and x */
	 vec3 s = floor(p + dot(p, vec3(F3)));
	 vec3 x = p - s + dot(s, vec3(G3));
	 
	 /* calculate i1 and i2 */
	 vec3 e = step(vec3(0.0), x - x.yzx);
	 vec3 i1 = e*(1.0 - e.zxy);
	 vec3 i2 = 1.0 - e.zxy*(1.0 - e);
	 	
	 /* x1, x2, x3 */
	 vec3 x1 = x - i1 + G3;
	 vec3 x2 = x - i2 + 2.0*G3;
	 vec3 x3 = x - 1.0 + 3.0*G3;
	 
	 /* 2. find four surflets and store them in d */
	 vec4 w, d;
	 
	 /* calculate surflet weights */
	 w.x = dot(x, x);
	 w.y = dot(x1, x1);
	 w.z = dot(x2, x2);
	 w.w = dot(x3, x3);
	 
	 /* w fades from 0.6 at the center of the surflet to 0.0 at the margin */
	 w = max(0.6 - w, 0.0);
	 
	 /* calculate surflet components */
	 d.x = dot(random3(s), x);
	 d.y = dot(random3(s + i1), x1);
	 d.z = dot(random3(s + i2), x2);
	 d.w = dot(random3(s + 1.0), x3);
	 
	 /* multiply d by w^4 */
	 w *= w;
	 w *= w;
	 d *= w;
	 
	 /* 3. return the sum of the four surflets */
	 return dot(d, vec4(52.0));
}

vec3 _hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}


const vec3 RED = vec3(1., 0., 0.);
const vec3 GREEN = vec3(0., 1., 0.);
const vec3 WHITE = vec3(1.);
const vec3 BG = vec3(0.9);
const vec3 BLACK = vec3(0.);

uniform vec2 frame_size;
uniform vec2 sprite_sheet_size;
uniform float time_seed;
uniform vec3 color_1;
uniform vec3 color_2;
uniform float thickness;
uniform float expand;

vec4 fire(vec2 uv, float t, vec3 texture) {
    vec4 res;
    
    float cloud_mask = texture.b + 
		smoothstep(0.3, 0.8, 1. - length((uv - 0.5) * 1.2));
	
	float cloud = _noise(vec3(uv * 4., t * 0.7));
	float cloud_v = abs(cloud);
	
	vec3 color = cloud > 0. ? color_1 : color_2;
	
	if(length(color) < 0.01) {
		cloud_v = 0.;
	}
	
	float hard_cloud = clamp(cloud_v * 2., 0., 1.);
	float soft_cloud = clamp(cloud_v * 1.5, 0., 1.) * cloud_mask;
	
	float inner = smoothstep(0.5, 0.9, texture.g);
	float outer = 1. - smoothstep(thickness, 0.85, texture.r);
	
	float contour = texture.g * (1. - inner);
	
	res.a = max(outer, soft_cloud);
	
	res.rgb = mix(color, max(vec3(inner), hard_cloud * color), outer);
	
    // res.a = 1.;
	// res.rgb = soft_cloud * color;
	
	return res;
}

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
