shader_type canvas_item;

uniform vec4 layer0: hint_color;
uniform vec4 layer1: hint_color;
uniform vec4 layer2: hint_color;
uniform vec4 layer3: hint_color;
uniform int OCTAVES = 6;
uniform vec2 center = vec2(0.5, 0.8);

uniform float outer_threshold = 0.04;
uniform float layer0_threshold = 0.1;
uniform float layer1_threshold = 0.2;
uniform float layer2_threshold = 0.4;
uniform float x_offset = 0.0;

uniform float pixelated_amount = 20;
uniform float opacity = 1.0;


// https://godotengine.org/qa/40950/godot-3-0-3-1-how-to-make-a-random-number-in-shader
// dot product: idk why
// sin: creates wave like distribution
// fract: computes the fractional part of the argument
// function takes in coordinate and returns float value
float rand(vec2 coord) {
	return fract(sin(dot(coord, vec2(12.9898, 78.233)))* 43758.5453123);
}

// floor returns value equal to nearest integer thats less than or equal to
float noise(vec2 coord){
	// because we use floor, the rectangle corners are whole number coords
	vec2 i = floor(coord);  // eg. 7.3 -> 7
	// f is used to interpolate
	vec2 f = fract(coord); // eg. 7.3 -> 0.3
	
	// 4 corners of a rectangle surrounding our point
	// for random values for the corners of a rectangle
	float a = rand(i);										// top left corner
	float b = rand(i + vec2(1.0, 0.0));		// top right corner
	float c = rand(i + vec2(0.0, 1.0));		// bottom left corner
	float d = rand(i + vec2(1.0, 1.0));		// bottom right corner

	vec2 cubic = f * f * (3.0 - 2.0 * f);
	
	// mix a and b according to the x value (lerp)
	// + how far the point is moved down on the y axis
	// this is done not only for two edges, but for all four
	return mix(a, b, cubic.x) + (c - a) * cubic.y * (1.0 - cubic.x) + (d - b) * cubic.x * cubic.y;
}

// adds smaller detail to the noise function
// fractal brownian motion
float fbm(vec2 coord) {
	float value = 0.0;
	float scale = 0.5;

	for (int i = 0; i < OCTAVES; i++) {
		value += noise(coord) * scale;
		coord *= 2.0;
		scale *= 0.5;
	}
	return value;
}

float overlay(float base, float top) {
	if (base < 0.5) {
		return 2.0 * base * top;
	}
	
	return 1.0 - (2.0 * (1.0 - base) * (1.0 - top));
}

float cirlce_shape(vec2 coord, float radius) {
	float dist = distance(coord, vec2(0.5, 0.5));
	
	return 1.0 - dist;
}

float egg_shape(vec2 coord, float radius){
	vec2 diff = abs(coord - center);

	if (coord.y < center.y) {
		diff.y /= 2.0;
	} else {
		diff.y *= 2.0;
	}
	
	float dist = sqrt(diff.x * diff.x + diff.y * diff.y) / radius;
	dist = min(1.0, max(0.0, dist));
	float value = sqrt(1.0 - dist * dist);
	return clamp(value, 0.0, 1.0);
}

void fragment() {
	float time = TIME;
	vec2 distortion = vec2((floor(1.0 - UV.y) / float(pixelated_amount)), 0.0);
	vec2 uv = floor(UV * float(pixelated_amount)) / float(pixelated_amount);
	uv.x += x_offset * floor((1.0 - uv.y) * 0.9 * pixelated_amount * 0.5) * (1.0 / pixelated_amount * 0.5);
	
	vec2 coord = uv * 8.0;
	vec2 fbmcoord = coord / 6.0;

	float egg_s = egg_shape(uv, 0.4);
	egg_s += egg_shape(uv, 0.2) / 2.0;

	float noise1 = noise(coord + vec2(time * 0.25, sin(time * 4.0)));
	float noise2 = noise(coord + vec2(cos(time * 0.5), time * 7.0));
	float combined_noise = (noise1 + noise2) / 2.0;
	
	float fbm_noise = fbm(fbmcoord + vec2(0.0, time * 3.0));
	fbm_noise = overlay(fbm_noise, uv.y);

	float combined = combined_noise * fbm_noise * egg_s;

	if (combined > 0.4)
		COLOR = layer3;
	else if (combined > 0.17)
		COLOR = layer2;
	else if (combined > 0.08)
		COLOR = layer1;
	else if (combined > 0.05) 
		COLOR = layer0;
	else
		COLOR = vec4(vec3(0.0), 0.0);
		
	COLOR.a *= opacity;
}