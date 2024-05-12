shader_type sky;

uniform vec3 sky_color : source_color;
uniform sampler2D cloudy;
uniform float density = 0.3;
uniform vec3 dark_color: source_color;
uniform vec2 wind = vec2(3.2, 1.0);

void sky() {
	// Called for every visible pixel in the sky background, as well as all pixels
	// in the radiance cubemap.
	vec2 direction = (TIME * wind) * .005;
	vec3 stormy = mix(texture(cloudy, SKY_COORDS + direction).rgb, dark_color, 0.2);
	vec3 final_color = mix(sky_color, texture(cloudy, SKY_COORDS + direction).rgb, density);
	
	COLOR = final_color;
}
