shader_type spatial;

uniform sampler2D albedo_texture : hint_albedo;
uniform vec4 albedo_color : hint_color = vec4(1.0);
uniform sampler2D specular_brush_texture : hint_black;
uniform sampler2D specular_gradient_texture : hint_albedo;

uniform float shadow_size : hint_range(-1.0, 1.0) = 0.4;
uniform float side_shine_strength = 3.0;
uniform float backhalo_size : hint_range(0.0, 1.0) = 0.3;
uniform float specular_size : hint_range(0.0, 1.0) = 0.9;
uniform float specular_offset = 0.5;
uniform float specular_strength = 1.0;
uniform float specular_tex_size = 10.0;
uniform bool use_shade_fresnel = true;
uniform float shade_fresnel_darkness = 0.8;

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

vec3 contrast(vec3 c0l0r, float c0ntrast){
	return ((c0l0r - 0.5f) * max(c0ntrast, 0.0)) + 0.5f;
}

void fragment(){
	vec3 tex_col = texture(albedo_texture, UV).rgb;
	ALBEDO = tex_col * albedo_color.rgb;
}

void light(){
	float NdotL = dot(NORMAL, LIGHT);
	float VdotL = dot(VIEW, LIGHT);
	
	// Creating Basic Lighting and Shadows
	float step_lit = step(shadow_size, NdotL);
	float step_dark = step(NdotL, shadow_size);
	vec3 light_buffer = clamp(vec3(step_lit), 0.0, 1.0) * ATTENUATION * ALBEDO * LIGHT_COLOR;
	vec3 shadow_buffer = ALBEDO * step_dark;
	vec3 basic_toon = light_buffer + shadow_buffer;
	
	// Back Halo Shine
	float halo_fresnel = fresnel(3.0, NORMAL, VIEW);
	vec3 backhalo = vec3(step(backhalo_size, halo_fresnel * -VdotL));
	backhalo *= ALBEDO;
	
	// Side Shine
	float ss_buffer = -((-VdotL-0.5) + (NdotL-0.3)*4.0);
	ss_buffer = clamp(ss_buffer, 0.2, 1.1);
	ss_buffer = step(ss_buffer, fresnel(8.0, NORMAL, VIEW));
	vec3 side_shine = vec3(ss_buffer) * ALBEDO * side_shine_strength;
	
	vec3 final_light = backhalo + basic_toon;
	final_light += side_shine;
	
	// Specular Brushed Lighting
	float specular_buffer = UV.y;
	specular_buffer += (contrast(texture(specular_brush_texture, UV.xx * 10.0 * specular_tex_size).rgb, 0.4).r - specular_offset);
	specular_buffer += (contrast(texture(specular_brush_texture, UV.xx * 5.0 * specular_tex_size).rgb, 0.4).r - specular_offset);
	specular_buffer -= (INV_CAMERA_MATRIX * vec4(0.0,0.0,1.0,0.0)).y * 0.3;
	specular_buffer = texture(specular_gradient_texture, vec2(specular_buffer, 0.0)).r;
	specular_buffer *= contrast(texture(specular_brush_texture, UV.xx * 12.0).rgb, 0.9).r;
	specular_buffer = step(0.2, specular_buffer);
	specular_buffer *= clamp(VdotL * NdotL, 0.0, 1.0) * clamp(NdotL, 0.0, 1.0);
	
	// Shade Fresnel for Hair
	if (use_shade_fresnel){
		float shade_fresnel = fresnel(3.0, NORMAL, VIEW);
		shade_fresnel = step(backhalo_size, shade_fresnel * VdotL);
		shade_fresnel *= clamp(NdotL, 0.0, 1.0);
		if (shade_fresnel > 0.5){
			final_light *= 1.0 - shade_fresnel_darkness;
		}
	}
	
	DIFFUSE_LIGHT += final_light * clamp(LIGHT_COLOR, 0.0, 1.0);
	SPECULAR_LIGHT = vec3(specular_buffer) * specular_strength * ALBEDO;
}
