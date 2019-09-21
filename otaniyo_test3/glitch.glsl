
#ifdef GL_ES
precision mediump float;
precisioun mediump int;
#endif

uniform vec4 rectPosition; // x, y, w, h (in 0..1 units (?))
uniform vec2 rectOffset;
uniform float colorSpreadX;
uniform float brightnessAdd;

uniform sampler2D texture;
uniform sampler2D mask;
varying vec4 vertTexCoord;
varying vec4 vertColor;

// All components are in the range [0…1], including hue.
vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

// All components are in the range [0…1], including hue.
vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
    vec4 color = texture2D(texture, vertTexCoord.st);
    float x1 = rectPosition.x;
    float x2 = rectPosition.x + rectPosition.z;
    float y1 = rectPosition.y;
    float y2 = rectPosition.y + rectPosition.w;
    //TODO: different amount for different channels
    if(x1 < vertTexCoord.s && vertTexCoord.s < x2 &&
       y1 < vertTexCoord.t && vertTexCoord.t < y2) {
        vec2 pos = vertTexCoord.st - rectOffset;
        pos.y = 1.f - pos.y; // buffer y coordinates are flipped because opengl
        vec3 c = vec3(texture2D(mask, pos).r,
                      texture2D(mask, pos + vec2( colorSpreadX, 0)).g,
                      texture2D(mask, pos - vec2(-colorSpreadX, 0)).b);
        c = hsv2rgb(rgb2hsv(c) * vec3(1, 0.9, 1) + vec3(0, 0, brightnessAdd));
        color = vec4(c, texture2D(mask, pos).a);
        //color = vec4(1, 1, 1, 1);
    }

    gl_FragColor = color;
}
