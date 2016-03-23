// Based on GPU Gems 3
// http://http.developer.nvidia.com/GPUGems3/gpugems3_ch27.html
#version 450

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D gbuffer0;
uniform sampler2D gbuffer1; 
uniform sampler2D gbuffer2;

uniform sampler2D tex;
uniform mat4 prevVP;
uniform mat4 invVP;

in vec2 texCoord;

vec2 getVelocity(vec2 texCoord, float depth) {
	// Get the depth buffer value at this pixel  
	float zOverW = depth;
	// H is the viewport position at this pixel in the range -1 to 1
	vec4 H = vec4(texCoord.x * 2.0 - 1.0, (texCoord.y) * 2.0 - 1.0, zOverW, 1.0);  
	// Transform by the view-projection inverse
	vec4 D = invVP * H;  
	// Divide by w to get the world position
	vec4 worldPos = D / D.w;
	
	// Current viewport position
	vec4 currentPos = H;
	// Use the world position, and transform by the previous view-projection matrix
	vec4 previousPos = prevVP * worldPos;
	previousPos /= previousPos.w;
	// Use this frame's position and last frame's to compute the pixel velocity
	vec2 velocity = (currentPos - previousPos).xy / 40.0;
	return velocity;
}

void main() {	
	vec4 g0 = texture(gbuffer0, texCoord);
	float depth = g0.a;

	float blurScale = 1.0; //currentFps / targeFps;
	vec2 velocity = getVelocity(texCoord, depth) * blurScale;
	
	const int samples = 8;  
	vec4 color = texture(tex, texCoord);
	vec2 offset = texCoord;
	// for(int i = 1; i < samples; ++i) {
		// Sample the color buffer along the velocity vector
		// offset += velocity;  
   		// color += texture(tex, offset);  
		
		offset += velocity;  
   		color += texture(tex, offset);  

		offset += velocity;  
   		color += texture(tex, offset);  
		
		offset += velocity;  
   		color += texture(tex, offset);  
		
		offset += velocity;  
   		color += texture(tex, offset);  
		
		offset += velocity;  
   		color += texture(tex, offset);  
		
		offset += velocity;  
   		color += texture(tex, offset);  
		
		offset += velocity;  
   		color += texture(tex, offset);  
		
		offset += velocity;  
   		color += texture(tex, offset);  
	// }
	
	vec4 finalColor = color / samples; 
	gl_FragColor = finalColor;
}