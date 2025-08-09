#define PI 3.1415
#define COLOR1  vec3(1.000,1.000,0.878)
#define COLOR2 vec3(0.4, 0.3, 0.2)
#define ITERATIONS 24
#define ANIMATION_SPEED 0.02
#define INNER_SEPARATION 0.5
#define OUTER_SEPARATION 1.2
#define RADIUS 0.4
#define INTENSITY 0.0015

mat2 r2d(float a) {
    float c = cos(a), s = sin(a);
    return mat2(
        c, s,
        -s, c
    );
}

vec2 get_uv(vec2 pos) {
    vec2 uv = pos.xy / iResolution.xy;
    uv = uv * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;
    return uv;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = get_uv(fragCoord);
    vec2 mouse_uv = get_uv(iMouse.xy);
    uv -= mouse_uv;

    float rot = iTime * ANIMATION_SPEED;
    uv = r2d(rot) * uv;

    vec3 shape = vec3(0.0);
    vec3 shape2 = vec3(0.0);
    float angle = 0.0;
    float angle2 = 0.11;

    for (int i = 0; i < 24; i++) {
        float dist =
            length(uv / vec2(0.9, 0.1))
                - RADIUS;
        float denom = max(abs(dist), 0.002);
        float f = INTENSITY / denom;
        uv *= r2d(angle);

        shape += f * COLOR1;
    }

    for (int i = 0; i < ITERATIONS; i++) {
        float dist =
            length(uv / vec2(1.2, 0.3))
                - RADIUS;
        float denom = max(abs(dist), 0.002);
        float f = INTENSITY / denom;
        uv *= r2d(angle2);

        shape2 += f * COLOR1;
    }

    shape = shape + shape2;
    shape = asinh(shape) / asinh(vec3(1.0));
    fragColor = vec4(shape, shape);
}
