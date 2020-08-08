shader_type canvas_item;
uniform float pixelate_amount = 100.0;


void fragment() {
	vec2 uv = UV;
	uv.x -= floor((1.0 - uv.y) * 0.25 * pixelate_amount) * (1.0 / pixelate_amount);
	COLOR = texture(TEXTURE, floor(uv * pixelate_amount) / pixelate_amount);
	//COLOR = vec4(floor(UV * 10.0) / 10.0, 0.0, 1.0);
}