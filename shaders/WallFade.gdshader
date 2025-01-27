shader_type spatial;

render_mode next_pass;

uniform float fade_gradient_position : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec4 albedo = texture(ALBEDO_TEXTURE, UV);
    float fade = smoothstep(fade_gradient_position - 0.1, fade_gradient_position, VERTEX.y);
    albedo.a *= fade;
    ALBEDO = albedo.rgb;
    ALPHA = albedo.a;
}
