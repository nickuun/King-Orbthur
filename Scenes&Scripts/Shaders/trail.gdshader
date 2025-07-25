shader_type canvas_item;
render_mode unshaded, blend_mix;

// — your uniforms —    
uniform vec2   velocity;      // in pixels per second: your script fills this each frame
uniform vec2   screen_size;   // your script fills this once (viewport size)
uniform int    segments    : hint_range(1, 32)   = 8;    // how many ghost‐copies
uniform float  length      : hint_range(0.0, 1.0) = 0.3;  // how far back in UV‐space they go
uniform float  falloff     : hint_range(0.1, 5.0) = 1.5;  // power curve for fading
uniform bool   pixel_snap  = true;                       // keep it crisp / nearest‐filtered

void fragment() {
    vec2 base_uv = UV;
    vec2 uv_off  = velocity / screen_size;  // convert px→UV units    

    vec4 accum   = vec4(0.0);
    float totalW = 0.0;

    // sample current + trailing ghosts
    for (int i = 0; i <= segments; i++) {
        float t = float(i) / float(segments);
        vec2 u = base_uv - uv_off * length * t;
        if (pixel_snap) {
            u = floor(u * screen_size) / screen_size;
        }
        float w = pow(1.0 - t, falloff);
        accum   += texture(TEXTURE, u) * w;
        totalW  += w;
    }

    // normalize, output
    vec4 col = accum / totalW;
    COLOR = col;
}
