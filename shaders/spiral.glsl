
float Layer(vec2 uv, float thickness) {
    vec2 st = vec2(atan(uv.x, uv.y), length(uv));
    uv = vec2(st.x/6.2831+.5-iTime*.2 + st.y, st.y + smoothstep(0., 6., thickness));
    float x = uv.x*10.;
    float m = min(fract(x), fract(1.-x));
    float c = smoothstep(0., .01, m*.3-uv.y+.2);
    return c;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord - .5 * iResolution.xy)/iResolution.y;
    vec3 col = vec3(0);
    float c = Layer(uv/2., 0.);
    for(float i = 0.; i < 3.0; i+=1.0) {
        float even = mod(i, 2.);
        float layer = Layer(uv*i, i/4.);
        if(even == 0.) {
            c += layer;
        } else {
            c -= layer;
        }
    }
    col = vec3(0, c, 0);
    fragColor = vec4(col,1);
}