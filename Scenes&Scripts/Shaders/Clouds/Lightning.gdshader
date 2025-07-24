shader_type canvas_item;

// — COLORS & MASKING —
uniform vec4 lightning_color    : source_color = vec4(0.97,0.89,0.85,1.0);
                                 // your bolt tint & alpha
// will only draw where your sprite’s alpha > 0
// so you can spawn this as a full‐screen rect or match your bolt mask

// — SHAPE / SEGMENTS —
uniform float size              : hint_range(0.0,1.0) = 0.005;
                                 // thickness (in UV units)
uniform float width             : hint_range(0.0,1.0) = 0.4;
                                 // max horizontal deviation
uniform float cycle             : hint_range(0.0,50.0) = 10.0;
                                 // how many zig segments over the full Y
uniform float offset_x          : hint_range(0.0,1.0) = 0.5;
                                 // horizontal center of your bolt
uniform float seed              : hint_range(0.0,10.0) = 0.0;
                                 // tweak this per-instance for different shapes

// — GLOW AROUND THE BOLT —
uniform float glow_intensity    : hint_range(0.0,1.0) = 0.9;

// simple triangle‐wave for sharp lines
float tri(float x) {
    return abs(fract(x) - 0.5) * 2.0;
}

void fragment() {
    // 1) build a 1D “jagged” chain by summing  
    //    several triangle waves at different frequencies:
    float y = UV.y;
    float o1 = (tri(y * cycle     + seed      ) - 0.5) * width;
    float o2 = (tri(y * cycle * 1.7 + seed * 1.3) - 0.5) * (width * 0.6);
    float o3 = (tri(y * cycle * 2.3 + seed * 2.7) - 0.5) * (width * 0.3);
    float total_offset = o1 + o2 + o3;

    // 2) carve out a thin line around (offset_x + total_offset):
    float dx = abs(UV.x - (offset_x + total_offset));
    float bolt = 1.0 - step(size, dx);

    // 3) add a soft radial glow centered at (offset_x, 0.5)
    float dist = distance(UV, vec2(offset_x, 0.5));
    float glow = smoothstep(0.0, glow_intensity, 1.0 - dist);

    // 4) composite color + glow, mask by your sprite’s alpha
    vec4 lit = lightning_color * bolt;
    lit.rgb += glow * lightning_color.rgb * bolt;
    float a = texture(TEXTURE, UV).a;
    COLOR = vec4(lit.rgb, lit.a * a);
}
