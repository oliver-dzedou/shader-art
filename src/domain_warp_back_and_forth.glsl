float random (in vec2 st) {
    return fract(sin(dot(st.xy,
                         vec2(12.9898,78.233)))*
        43758.5453123);
}

// Based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise (in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

// Based on Inigo Quilez @iq
// https://iquilezles.org/articles/fbm/
// https://iquilezles.org/articles/warp/
float fbm (vec2 uv, float gain) {
    float value = 0.0;
	float amplitude = 1.;
    float frequency = 0.;
    for (int i = 0; i < 6; i++) {
        value += amplitude * noise(uv);
        uv *= 2.;
        amplitude *= gain;
    }
    return value;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 uv = fragCoord/iResolution.y;
	float gain = sin(iTime*0.5);
	uv = uv*3. + sin(iTime*0.5);
	float color = fbm(fbm(fbm(uv, gain) + uv, gain) + uv, gain);
	float color2 = fbm(fbm(fbm(uv + gain, gain) + uv + gain, gain) + uv + gain, gain);
	vec3 f_color = mix(vec3(color) , vec3(color2), vec3(uv.x, uv.y, 1.));
	fragColor = vec4(f_color, 1.);
}
