shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear;
uniform float scale_y;
uniform float y_zoom;
uniform vec2 center;
uniform vec4 cast_color: source_color;
uniform sampler2D fast_noise : repeat_enable;

uniform vec2 wave_speed = vec2(0.03, 0.07);
uniform float wave_strength = 2.0;
void vertex() {
	VERTEX.y += sin(TIME) * 0.01;
}

void fragment() {
	vec2 uv = UV + wave_speed * TIME;
	vec2 noise = texture(fast_noise, uv).rg;
	float uv_height = SCREEN_PIXEL_SIZE.y /  TEXTURE_PIXEL_SIZE.y;
	vec2 reflected_uv = vec2(SCREEN_UV.x, SCREEN_UV.y - (uv_height * scale_y * UV.y * y_zoom));
	vec4 reflection = texture(screen_texture, reflected_uv);

	vec4 waves = texture(screen_texture, reflected_uv + noise * y_zoom * (wave_strength /100.0));
	//vec2 disp = normalize(UV - center);
	COLOR = waves + cast_color;
	//f


	//COLOR = texture(screen_texture, reflected_screen_uv);

}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
