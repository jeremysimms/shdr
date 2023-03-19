#version 100
out vec4 outColor;
uniform vec2 iResolution;
uniform float iTime;

mat2 r(float a) { //Rotate
    float s = sin(radians(a));
    float c = cos(radians(a));
    return mat2(c,-s,s,c);
}

void main()
{
    vec2 uv = gl_FragCoord.xy/iResolution.y;
    //store original uv coordinate 
    vec2 uvO = uv;
    mat2 rot = r(sin(iTime*.5)*5.);
    //take coord and scale it so the pattern repeats
    uv *= 4.;
    // rotate the camera
    uv *= rot;
    // move the camera
    uv += iTime*.4;
    // local uv for each tile
    vec2 gv = fract(uv);
    int tx = int(gv.y*512.);
    vec3 col = vec3(0);
    // tile indices from (0, 0) to (4, 4)
    vec2 id = floor(uv);
    // 4 second timer used to step animation frames
    float elapsedTime = mod(iTime*4., 4.);
    // amount to move each tile quadrant by per time step between t = 0 and t = 2 for vertical movements
    // and t = 2 and t = 4 for horizontal movements. alternates between up and down movements by the row
    // and col of the tile
    float deltaX = mod(id.y, 2.) == 0.? -smoothstep(0.,2., elapsedTime * 6.): smoothstep(0.,2., elapsedTime * 6.);
    float deltaY = mod(id.x, 2.) == 0.? -smoothstep(2., 4.0, elapsedTime) : smoothstep(2., 4.0, elapsedTime);
    // prevent the delta adjusted local UV coords from overflowing 
    float repeatX = mod(gv.x + deltaX , 1.);
    float repeatY = mod(gv.y + deltaY, 1.);
    // hard step on half the width and height of each delta adjusted tile to produce
    // each quadrant
    float x = step(.5, repeatX);
    float y = step(.5, repeatY);
    // check if we should color the pixel
    if(x == 1. && y == 1. || x == 0.  && y == 0.) {
        col.x = sin(iTime *.5 * 3.1)*.5 + .6;
        col.y = sin(iTime*.2 * 7.112)*.5 + .5;
        col.z = sin(iTime*.5 *10.21)*.5 + .5;
    }
    // Output to screen
    gl_FragColor = vec4(col,1.0);
}