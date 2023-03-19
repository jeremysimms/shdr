const int MAX_STEPS = 300;
const float MAX_DIST = 100.;
const float SURFACE_DIST = 0.01;


const int SPHERE = 1;
const int PLANE = 2;

struct ObjectDistance {
    int type;
    float dist;
};

struct Light {
    vec3 color; 
    vec3 diffuse;
    vec3 position;
};

const vec3 light = vec3(1., 6., 3.);

mat2 rot(float a) {
    float c=cos(a), s=sin(a);
    return mat2(c, -s, s, c);
}

ObjectDistance GetDist(vec3 p) {
    float r = 0.9;
    float warp = sin((p.y)*15.5+(iTime*10.))*.5 +.5;
    vec3 spherePos = vec3(0., 1.8, 4);
    float planeDist = dot(p, normalize(vec3(0,1,0))) + sin((p.x+p.z)*1.5+iTime*10.)*.3;
    float dist = length(p-spherePos)-r+warp*.2;
    float minDist = min(planeDist, dist);
    int type = 0;
    if(minDist == planeDist) {
        type = 2;
    }
    if(minDist == dist) {
        type = 1;
    }
    return ObjectDistance(type, minDist*.7);
}

ObjectDistance RayMarch(vec3 ro, vec3 rd) {
    float dist = 0.;
    int type = 0;
    float diff = 0.;
    for(int i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro + rd*dist;
        ObjectDistance o = GetDist(p);
        dist += o.dist;
        type = o.type;
        if(dist < 0.01) {
            type = o.type;
            break;
        }
        if(dist > MAX_DIST) {
            type = 0;
            break;
        }
    }
    return ObjectDistance(type, dist);
}

vec3 GetNormal(vec3 p) {
    vec2 e = vec2(.01, 0);
    ObjectDistance d0 = GetDist(p);
    ObjectDistance d1 = GetDist(p-e.xyy);
    ObjectDistance d2 = GetDist(p-e.yxy);
    ObjectDistance d3 = GetDist(p-e.yyx);
    vec3 n = d0.dist - vec3(d1.dist, d2.dist, d3.dist);
    
    return normalize(n);
}

float GetLight(vec3 p, float dist) {
    vec3 lightPos = vec3(-1, 6, 3);
    lightPos.xz += vec2(sin(iTime), cos(iTime))*2.;
    vec3 l = normalize(lightPos-p);
    vec3 n = GetNormal(p);
    float dif = clamp(dot(n, l), 0., 1.);
    ObjectDistance d = RayMarch(p+n*SURFACE_DIST*2., l);
    if(d.dist<length(lightPos-p)) dif *= .1;
    return dif;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = (fragCoord - .5*iResolution.xy)/iResolution.y;
    // Time varying pixel color
    vec3 col = vec3(0);
    vec3 ro = vec3(0, 1, 0);
    vec3 rd = normalize(vec3(uv.x, uv.y, 1.));
    ObjectDistance d = RayMarch(ro, rd);
    if(d.type == 1 || d.type == 2) {
        vec3 p = ro + rd*d.dist;
        float diff = GetLight(p, d.dist);
        col = vec3(diff);
        if(d.type == 1) col *= vec3(1,0,0);
    }
    // Output to screen
    fragColor = vec4(col,1.0);
}
