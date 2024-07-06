#version 450
#extension GL_ARB_separate_shader_objects : enable

layout(set = 1, binding = 1) uniform sampler texSampler;
layout(set = 2, binding = 2) uniform texture2D tex;

layout(push_constant) uniform PushBuffer {
    mat4 model;
    vec4 colourMod;
    vec4 textureCoords;
} pushBuffer;

layout(location = 1) in vec2 fragTexCoord;

layout(location = 0) out vec4 outColor;

void main() {
    vec4 colour = texture(sampler2D(tex, texSampler), fragTexCoord);
    vec4 colourUp = texture(sampler2D(tex, texSampler), vec2(fragTexCoord.x, fragTexCoord.y - 1));
    vec4 colourDown = texture(sampler2D(tex, texSampler), vec2(fragTexCoord.x, fragTexCoord.y + 1));
    vec4 colourLeft = texture(sampler2D(tex, texSampler), vec2(fragTexCoord.x - 1, fragTexCoord.y));
    vec4 colourRight = texture(sampler2D(tex, texSampler), vec2(fragTexCoord.x + 1, fragTexCoord.y));
    if (colour.a == 0 && (colourDown.a != 0 || colourUp.a != 0 || colourLeft.a != 0 || colourRight.a != 0)) {
        outColor = vec4(0, 0.4, 0.7, 1);
    } else {
        outColor = vec4(0, 0, 0, 0);
    }
}