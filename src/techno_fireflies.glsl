#define PI 3.14159265359
#define ANIM_SPEED PI*4.0
#define RADIUS_ANIM_SPEED PI*2.0

#define SCALE       8.
#define GRID_COUNT 0.4
#define DOT_FREQ    0.2
#define DOT_RADIUS .007

#define DIST_MODIFIER 2.2

#define CIRCLE_RADIUS 0.15

#define FALLOFF_MODIFIER 0.11
#define BRIGHTNESS_BOOST 3.0

#define COLOR_BLUE vec3(0.1, 0.1, 0.7)
#define COLOR_RED vec3(0.7, 0.1, 0.1)
#define COLOR_GREEN vec3(0.1, 0.7, 0.1)

float sdf_disk(vec2 uv, float radius, vec2 center) {
    return distance(uv, center) - radius;
}

float hash1(float x) {
    return fract(sin(x * 12.9898) * 43758.5453123);
}

vec2 hash2(vec2 p) {
    p = vec2(
            dot(p, vec2(127.1, 311.7)),
            dot(p, vec2(269.5, 183.3))
        );
    return fract(sin(p) * 43758.5453123);
}

// https://www.shadertoy.com/view/XtsczM
float draw_dotgrid(vec2 uv, float scale) {
    vec2 uv_repeat = mod(uv - .5 * DOT_FREQ, DOT_FREQ) - .5 * DOT_FREQ;
    float dot_aa = 4. * scale / iResolution.y;
    float dot_radius = DOT_RADIUS;
    return smoothstep(dot_aa, .0, sdf_disk(uv_repeat, dot_radius, vec2(0)));
}

float voronoi(vec2 uv, float time, float grid_count) {
    vec2 scaled_uv = uv * grid_count;
    vec2 id = floor(scaled_uv);
    vec2 frac = fract(scaled_uv);

    float min_dist = 1e10;
    for (int y = -1; y <= 1; ++y) {
        for (int x = -1; x <= 1; ++x) {
            vec2 neighbor = vec2(float(x), float(y));
            vec2 rnd = hash2(id + neighbor);
            vec2 anim = sin(time + rnd * ANIM_SPEED);
            vec2 seed_pos = neighbor + rnd + anim;
            float d = length(frac - seed_pos);
            min_dist = min(min_dist, d);
        }
    }
    return min_dist;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = SCALE * (2. * fragCoord - iResolution.xy) / iResolution.y;
    vec3 dotgrid = vec3(draw_dotgrid(uv, SCALE));
    float dist = voronoi(uv, iTime, GRID_COUNT);
    vec2 cell_id = floor(uv * GRID_COUNT);
    float rnd = hash2(cell_id).x;
    dist *= (sin(iTime * RADIUS_ANIM_SPEED * rnd)) + DIST_MODIFIER;
    float falloff = (1.0 - dist / CIRCLE_RADIUS) + FALLOFF_MODIFIER;
    vec3 color = dotgrid * COLOR_BLUE * BRIGHTNESS_BOOST * falloff;
    fragColor = vec4(color, 1.0);
}
