#ifdef GL_ES
precision mediump float;
precisioun mediump int;
#endif

uniform float feedbackAmount;
uniform float feedbackScale;
uniform vec2 feedbackCenter;

uniform sampler2D texture;
varying vec4 vertTexCoord;
varying vec4 vertColor;


void main() {
	//vec2 center = vec2(0.5, 0.5);
	//vec2 xy = vertTexCoord.st - center;
	vec2 xy = vertTexCoord.st - feedbackCenter;

	gl_FragColor = texture2D(texture, xy * feedbackScale + feedbackCenter) * feedbackAmount * vertColor;
	gl_FragColor += texture2D(texture, vertTexCoord.st) * (1 - feedbackAmount) * vertColor;
	//gl_FragColor *= 1.1;

}
