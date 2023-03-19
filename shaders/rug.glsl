vec2 triangle_wave(vec2 a){
    return abs(fract((a+vec2(1.,0.5))*1.5)-.5);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    fragColor = vec4(0.0);
    vec3 col = vec3(0.);
    float t1 = .5;
    vec2 uv = (fragCoord)/iResolution.y/t1/2.0;
    float time1 = iTime/64.;
    uv += vec2(time1/2.0,time1/3.0)/t1/4.0+(vec2(cos(time1),sin(time1)))*8./t1;
    float scale = 1.5;
    vec2 t2 = vec2(0.);
    vec3 col1 = col;
    float multiplier = 2.;
    if(iMouse.z>.5)
    uv = uv.xy + iMouse.xy / iResolution.xy/t1;
    for(int k = 0; k < 6; k++){
        uv = (uv-t2/scale)/scale;
        t2 = triangle_wave(uv-.5);
        uv = -(t2+triangle_wave(uv.yx));
        col.x = min(length(uv)-col.x,col.x*(multiplier));
        col = abs(col.yzx-vec3(1.-col.x))/multiplier;
    }
    fragColor =
        vec4(col*multiplier,1.0);
}