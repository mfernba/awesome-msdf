#version 330

#define CHANGE_SPEED 1.2
#define CHAR_COUNT 4

uniform mat4 viewProj;
uniform mat4 transform;
uniform float time;

layout (location = 0) in vec3 pos;
layout (location = 1) in vec2 texCoord;

out vec2 uvCoord;
flat out int texIndex;

void main() {
	texIndex = int(time * CHANGE_SPEED) % CHAR_COUNT ;
	uvCoord = vec2(1-texCoord.x, texCoord.y);
	gl_Position = viewProj * transform * vec4(pos, 1.0);
}