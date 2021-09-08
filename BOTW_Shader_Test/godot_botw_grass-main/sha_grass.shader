shader_type spatial;
render_mode cull_disabled;

uniform vec4 color_top:hint_color = vec4(1,1,1,1);
uniform vec4 color_bottom:hint_color = vec4(0,0,0,1);

uniform float deg_sway_pitch = 80.0;
uniform float deg_sway_yaw = 45.0;

uniform float wind_scale = 4.0;
uniform float wind_speed = 1.0;

varying float wind;

const vec3 UP = vec3(0,1,0);
const vec3 RIGHT = vec3(1,0,0);

const float PI = 3.14159;
const float DEG2RAD = (PI / 180.0);

uniform vec3 wind_direction = vec3(0,0,-1);

mat3 mat3_from_axis_angle(float angle, vec3 axis) {
	float s = sin(angle);
	float c = cos(angle);
	float t = 1.0 - c;
	float x = axis.x;
	float y = axis.y;
	float z = axis.z;
	return mat3(
		vec3(t*x*x+c,t*x*y-s*z,t*x*z+s*y),
		vec3(t*x*y+s*z,t*y*y+c,t*y*z-s*x),
		vec3(t*x*z-s*y,t*y*z+s*z,t*z*z+c)
	);
}

vec2 random2(vec2 p) {
	return fract(sin(vec2(
		dot(p, vec2(127.32, 231.4)),
		dot(p, vec2(12.3, 146.3))
	)) * 231.23);
}

float worley2(vec2 p) {
	float dist = 1.0;
	vec2 i_p = floor(p);
	vec2 f_p = fract(p);
	for(int y=-1;y<=1;y++) {
		for(int x=-1;x<=1;x++) {
			vec2 n = vec2(float(x), float(y));
			vec2 diff = n + random2(i_p + n) - f_p;
			dist = min(dist, length(diff));
		}
	}
	return dist;
}

void vertex() {
	NORMAL = UP;
	vec3 vertex = VERTEX;
	vec3 wind_direction_normalized = normalize(wind_direction);
	float time = TIME * wind_speed;
	vec2 uv = (WORLD_MATRIX * vec4(vertex,-1.0)).xz * wind_scale;
	uv += wind_direction_normalized.xz * time;
	wind = pow(worley2(uv),2.0) * UV2.y;
	
	mat3 to_model = inverse(mat3(WORLD_MATRIX));
	vec3 wind_forward = to_model * wind_direction_normalized;
	vec3 wind_right = normalize(cross(wind_forward, UP));
	
	float sway_pitch = ((deg_sway_pitch * DEG2RAD) * wind) + INSTANCE_CUSTOM.z;
	float sway_yaw = ((deg_sway_yaw * DEG2RAD) * sin(time) * wind) + INSTANCE_CUSTOM.w;
	
	mat3 rot_right = mat3_from_axis_angle(sway_pitch, wind_right);
	mat3 rot_forward = mat3_from_axis_angle(sway_yaw, wind_forward);
	
	vertex.xz *= INSTANCE_CUSTOM.x;
	vertex.y *= INSTANCE_CUSTOM.y;

	VERTEX = rot_right * rot_forward * vertex;

	COLOR = mix(color_bottom, color_top, UV2.y);
}

void fragment() {
	float side = FRONT_FACING ? 1.0 : -1.0;
	NORMAL = NORMAL * side;
	ALBEDO = COLOR.rgb;
	SPECULAR = 0.5;
	ROUGHNESS = clamp(1.0 - (wind * 1.2), 0.0, 1.0);
}