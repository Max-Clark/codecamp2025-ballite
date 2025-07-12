shader_type canvas_item;

uniform sampler2D background_texture;

varying vec2 world_position;

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
    vec4 original = texture(TEXTURE, UV);

    // Convert world position to background UV
    vec2 bg_uv = world_position / vec2(textureSize(background_texture, 0));

    vec4 background = texture(background_texture, bg_uv);

    COLOR = vec4(background.rgb, original.a);
}