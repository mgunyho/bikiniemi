
#ifdef GL_ES
precision mediump float;
precisioun mediump int;
#endif

uniform vec4 rectPosition; // x, y, w, h (in 0..1 units (?))
uniform vec2 rectOffset;

uniform sampler2D texture;
varying vec4 vertTexCoord;
varying vec4 vertColor;

void main() {
    vec4 color = texture2D(texture, vertTexCoord.st);
    float x1 = rectPosition.x;
    float x2 = rectPosition.x + rectPosition.z;
    float y1 = rectPosition.y;
    float y2 = rectPosition.y + rectPosition.w;
    //TODO: different amount for different channels
    if(x1 < vertTexCoord.s && vertTexCoord.s < x2 &&
       y1 < vertTexCoord.t && vertTexCoord.t < y2) {
        color = texture2D(texture, vertTexCoord.st - rectOffset);
    }

    gl_FragColor = color;
}
