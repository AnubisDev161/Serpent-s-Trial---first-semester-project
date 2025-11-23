shader_type canvas_item;
uniform float scrolling_speed = 1.0;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 moving_uv = vec2(UV.x-(TIME * scrolling_speed), UV.y);
	vec4 new_color = texture(TEXTURE, moving_uv);
	COLOR = new_color;
	
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
