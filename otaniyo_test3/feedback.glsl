#ifdef GL_ES
precision mediump float;
precisioun mediump int;
#endif

uniform float feedbackAmount;
uniform float feedbackScale;
uniform vec2 feedbackCenter;
uniform float feedbackAngle;
uniform float feedbackHueSpeed;
uniform float feedbackBrightnessAdd;


uniform sampler2D texture;
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

mat2 rotationMatrix(float angle) {
	float t = angle;
	return mat2(cos(t), -sin(t),
	            sin(t),  cos(t));
}

void main() {
	vec2 center = vec2(0.5, 0.5);
	//vec2 xy = vertTexCoord.st - center;
	vec2 xy = rotationMatrix(feedbackAngle) * (vertTexCoord.st - feedbackCenter);

	vec4 color = texture2D(texture, xy * feedbackScale + feedbackCenter) * feedbackAmount * vertColor;
	color += texture2D(texture, vertTexCoord.st) * (1 - feedbackAmount) * vertColor;

	color.rgb = hsv2rgb(rgb2hsv(color.rgb) + vec3(feedbackHueSpeed, 0, feedbackBrightnessAdd));

	gl_FragColor = color;
}
