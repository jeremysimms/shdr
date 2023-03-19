float Noise21(vec2 p)
{
    p = fract (p * vec2 (234.34, 435.345));
    p += dot(p,p +34.23);
    
    return fract(p.x * p.y);
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = (fragCoord - .5 *iResolution.xy)/iResolution.y;

    // Time varying pixel color
    vec3 col = vec3(0);
    
 
    uv *= 10.;
    uv += iTime * 2.;
    
    vec2 gv = fract(uv) - .5;
    vec2 idBox = floor(uv);
    
    float n = Noise21(idBox); 
    
    float width = .25;
    
    if (n<.5) 
    {
		gv.x *=  -1.;
	}
	
    float d = abs(abs(gv.x+gv.y)-.5);
    
    float mask = smoothstep(.01,-.01,d- width);
    
    col += mask;
    col += cos(vec3(0,5,10));
    
    fragColor = vec4(col,1.0);
}