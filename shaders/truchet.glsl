#version 140
out vec4 outColor;
uniform vec2 iResolution = vec2(640, 480);
uniform float iTime = 0;

float Hash21(vec2 p) {
    p = fract(p * vec2(234.34, 435.34));
    p += dot(p, p+34.23);
    return fract(p.x*p.y);
}

float Hash21_b(vec2 p) {
    p = fract(p * vec2(773.34, 856.24));
    p += dot(p, p+62.13);
    return fract(p.x*p.y);
}

float Layer(vec2 uv) {
  vec2 uvM = (uv*12.);
  vec2 gv = fract(uvM)-.5;
  vec3 col = vec3(0.);
  vec2 id = floor(uvM);
  float anim = (mod(iTime*.5, 2.0));
  float n = Hash21(id);
  float n2 = Hash21_b(id);
  if(mod(id.x, 2.) == 0.) gv.x *= -1.0;
  if(mod(id.y, 2.) == 0.) gv.y *= -1.0;
  
  if(n > .5) {
      gv.x *= -1.;
  }
  if(n2 > .5) {
      gv.y *= -1.;
  }
  float stepper = gv.x + gv.y + 1. - anim;
  float mask = step(.5, mod(stepper, 1.));
  return mask;
}



void main()
{
    vec2 uv = (gl_FragCoord.xy - .5 * iResolution.xy)/iResolution.y;
    vec3 col = vec3(0);
    float li = Layer(uv);
    col.g = li * 1.0;
    col.r = 0.;
    col.b = 0.;
    outColor = vec4(col,1.0);
}