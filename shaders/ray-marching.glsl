#version 100
#define MAX_STEPS 100
#define MAX_DIST 100.
#define SURF_DIST .01
precision highp float;
out vec4 outColor;
uniform vec2 iResolution;
uniform float iTime;

struct MarchOut {
    float d;
    bool obj;
};

float sphereY = 2.;
float sphereZ = 6.;
float sphereW = 1.;
float sphereX = 1.;


float GetPlaneHeight(vec3 p) {
    return (sin(p.z)+1.0)/2.;
}

float GetDist(vec3 p) {
	vec4 s = vec4(sphereX, sphereY, sphereZ, sphereW);
    
    float sphereDist =  length(p-s.xyz)-s.w;
    float planeDist = p.y;
    
    float d = min(sphereDist, planeDist);
    return d;
}

bool IsSphere(vec3 p) {
	vec4 s = vec4(sphereX, sphereY, sphereZ, sphereW);
    float sphereDist =  length(p-s.xyz)-s.w;
    float planeDist = p.y;
    if(sphereDist < planeDist) {
        return true;
    }
    return false;
}

MarchOut RayMarch(vec3 ro, vec3 rd) {
	float dO=0.;
    bool isSphere = false;
    for(int i=0; i<MAX_STEPS; i++) {
    	vec3 p = ro + rd*dO;
        float dS = GetDist(p);
        isSphere = IsSphere(p); 
        dO += dS;
        if(dO>MAX_DIST || dS<SURF_DIST) break;
    }
    MarchOut o = MarchOut(dO, isSphere);
    return o;
}

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

vec3 GetNormal(vec3 p) {
	float d = GetDist(p);
    vec2 e = vec2(.01, 0);
    
    vec3 n = d - vec3(
        GetDist(p-e.xyy),
        GetDist(p-e.yxy),
        GetDist(p-e.yyx));
    
    return normalize(n);
}

float GetLight(vec3 p) {
    vec3 lightPos = vec3(0, 5, 3);
    lightPos.xz += vec2(sin(iTime), cos(iTime))*2.;
    vec3 l = normalize(lightPos-p);
    vec3 n = GetNormal(p);
    
    float dif = clamp(dot(n, l), 0., 1.);
    MarchOut d = RayMarch(p+n*SURF_DIST*2., l);
    if(d.d<length(lightPos-p)) dif *= .1;
    
    return dif;
}

void main()
{
    vec2 uv = (gl_FragCoord.xy - .5 * iResolution.xy)/iResolution.y;
    vec3 col = vec3(0);
    vec3 ro = vec3(0, 1, 0);
    vec3 rd = normalize(vec3(uv.x, uv.y, 1.));
    MarchOut d = RayMarch(ro, rd);
    vec3 p = ro + rd * d.d;
    
    float dif = GetLight(p);
    col = vec3(dif);

    if(d.obj) {
            float li = Layer(uv);
            col.g = li * dif;
            col.r = 0.;
            col.b = 0.;
    }

    col = pow(col, vec3(.4545));
    
    gl_FragColor = vec4(col,1.0);
}