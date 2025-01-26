shader_type spatial;

uniform bool is_hovered = false;
uniform vec3 highlight_color = vec3(1.0, 1.0, 1.0); // Changed to white
uniform float edge_width = 0.1;
uniform vec3 base_color = vec3(0.8, 0.8, 0.8); // Base color when not highlighted

varying vec3 view_dir;

void vertex() {
    vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    vec3 camera_pos = INV_VIEW_MATRIX[3].xyz;
    view_dir = normalize(world_pos - camera_pos);
}

void fragment() {
    vec3 normal_dir = normalize(NORMAL);
    float edge_factor = pow(1.0 - dot(normal_dir, view_dir), 2.0);

    if (is_hovered && edge_factor > (1.0 - edge_width)) {
        ALBEDO = highlight_color;
        EMISSION = highlight_color; // Add emission for stronger outline
    } else {
        ALBEDO = base_color;
        EMISSION = vec3(0.0); // No emission when not highlighted
    }
}