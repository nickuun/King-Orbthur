shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float flicker_speed : hint_range(0.1, 10.0) = 3.5;
uniform float glow_strength : hint_range(0.0, 2.0) = 1.2;
uniform float arc_thickness : hint_range(0.0, 1.0) = 0.4;
uniform vec3 lightning_core : source_color = vec3(0.9, 0.95, 1.0);
uniform vec3 lightning_glow : source_color = vec3(0.2, 0.7, 1.0);

// === Pixel grid resolution for snapping ===
const vec2 resolution = vec2(320.0, 180.0); // adjust as needed

// === Classic hash noise ===
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(23.43, 41.32))) * 12345.6789);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);

    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void fragment() {
    // === Pixel-perfect UV snapping ===
    vec2 uv = floor(UV * resolution) / resolution;

    // Pixelate the arc effect further by downsampling to lower resolution
    vec2 pix_uv = floor(uv * resolution / 4.0) / (resolution / 4.0);

    float t = TIME * flicker_speed;

    // Generate wiggly lightning centerline using noise
    float center_x = 0.5 + (noise(vec2(pix_uv.y * 10.0, t * 0.3)) - 0.5) * 0.3;

    float dist_to_bolt = abs(pix_uv.x - center_x);
    float arc_mask = smoothstep(arc_thickness, 0.0, dist_to_bolt);

    // Add a nice glow falloff based on distance
    float glow = exp(-dist_to_bolt * 15.0) * glow_strength;

    // Base lightning color and glow
    vec3 color = lightning_glow * glow + lightning_core * arc_mask;

    // Flickering pulse effect
    float pulse = sin(t * 6.0 + pix_uv.y * 10.0);
    color *= 0.8 + 0.2 * pulse;

    // Blend with underlying texture alpha
    float alpha = texture(TEXTURE, uv).a;
    COLOR = vec4(color, alpha * max(arc_mask, glow));
}
