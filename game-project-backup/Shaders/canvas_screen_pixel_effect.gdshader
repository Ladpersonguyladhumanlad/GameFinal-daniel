shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;
uniform vec2 pixel_resolution = vec2(480.0, 270.0);

void fragment() {
    vec2 uv = SCREEN_UV * pixel_resolution;
    uv = floor(uv) / pixel_resolution;

    COLOR = texture(screen_tex, uv);
}
