shader_type canvas_item;

uniform vec4 outline_color: source_color;
uniform float size = 1.0;


void fragment() {
	vec2 texel_size = TEXTURE_PIXEL_SIZE * size;
	vec4 left = texture(TEXTURE, UV + vec2(-texel_size.x, 0.0));
	vec4 right = texture(TEXTURE, UV + vec2(texel_size.x, 0.0));
	
	vec4 up = texture(TEXTURE, UV + vec2(0.0, -texel_size.y));
	vec4 down = texture(TEXTURE, UV + vec2(0.0, texel_size.y));
	
	float has_neighbor = max(max(left.a, right.a), max(up.a, down.a));
	
	vec4 color = texture(TEXTURE, UV);
	
	COLOR = mix(color, outline_color, (1.0 - color.a) * has_neighbor );
}