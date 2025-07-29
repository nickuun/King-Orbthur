shader_type canvas_item;

#define iResolution 1.0 / SCREEN_PIXEL_SIZE
#define iTime TIME

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float flame_height : hint_range(0.5, 3.0) = 1.5;
uniform float flicker_speed : hint_range(0.1, 5.0) = 1.0;
uniform float intensity : hint_range(0.0, 1.0) = 1.0;
uniform vec3 fire_color_low : source_color = vec3(0.8, 0.2, 0.0);
uniform vec3 fire_color_high : source_color = vec3(1.0, 0.9, 0.2);

// Hash-based noise
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
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
    vec2 uv = UV;

    // Pixelated look
    vec2 pixel_uv = floor(uv * iResolution / 4.0) / (iResolution / 4.0);

    // Vertical flame flickering
    float t = iTime * flicker_speed;
    vec2 flame_uv = vec2(pixel_uv.x, pixel_uv.y * flame_height - t);

    float n = noise(flame_uv * 6.0);
    float flicker = smoothstep(0.2, 1.0, 1.0 - pixel_uv.y + n * 0.5);

    // Color blend based on intensity
    vec3 flame_color = mix(fire_color_low, fire_color_high, pow(flicker, 1.5)) * intensity;

    // Optional flame shimmer
    float shimmer = sin(uv.y * 30.0 + t * 5.0) * 0.05;
    flame_color += shimmer;

    // Apply texture alpha as mask
    float alpha = texture(TEXTURE, UV).a;

    COLOR = vec4(flame_color, alpha * flicker);
}
