shader_type canvas_item;

uniform sampler2D mask_texture;
uniform vec2 mask_world_position;
uniform vec2 mask_world_size = vec2(64.0, 64.0);
varying vec2 world_fragment_pos;

void vertex() {
    world_fragment_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
    vec2 mask_uv = (world_fragment_pos - mask_world_position) / mask_world_size;
    float mask_value = texture(mask_texture, mask_uv).r;
    vec4 sprite_color = texture(TEXTURE, UV);
    COLOR = sprite_color;
    COLOR.a *= mask_value;
}