#define PI               3.14159
#define SCALE            8.0
#define DOT_FREQ         0.5
#define MIN_DOT_RADIUS   0.00001
#define MAX_DOT_RADIUS   0.3
#define RADIUS           8.0
#define WAVE_COUNT       1.5
#define WAVE_SPEED       0.5

// inspired by https://www.shadertoy.com/view/Mltyz8

float sdf_disk(vec2 uv, float radius, vec2 center) {
    return distance(uv, center) - radius;
}

//https://www.shadertoy.com/view/XtsczM
float draw_dotgrid(vec2 uv, float scale, float dot_radius, float dot_frequency) {
    vec2 uv_repeat = mod(uv - .5 * dot_frequency, dot_frequency) - .5 * dot_frequency;
    float dot_aa = 4. * scale / iResolution.y;
    return smoothstep(dot_aa, 0.0, sdf_disk(uv_repeat, dot_radius, vec2(0)));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv01 = fragCoord / iResolution.xy;

    vec2 uv = SCALE * (2.0 * fragCoord - iResolution.xy) / iResolution.y;
    vec2 pos = uv * 0.5;

    float dist = distance(pos, uv);
    float ratio = clamp(dist / RADIUS, 0.0, 1.0);
    float inverse_ratio = 1.0 - ratio;
    float mask = 1.0 - step(RADIUS, dist);

    float phase = (ratio * WAVE_COUNT - iTime * WAVE_SPEED) * 2.0 * PI;
    float wave = 0.5 + 0.5 * sin(phase);
    float dot_radius = mix(MIN_DOT_RADIUS, MAX_DOT_RADIUS, wave);
    float grid = draw_dotgrid(uv, SCALE, dot_radius, DOT_FREQ);

    vec3 pastelA = vec3(0.2, 0.4, 0.8);
    vec3 pastelB = vec3(0.9, 0.7, 0.6);

    vec3 rgb = mix(pastelA, pastelB, wave);

    vec3 color = grid
            * rgb
            * inverse_ratio
            * mask
            * 1.5;

    fragColor = vec4(color, mask * 2.0);
}
