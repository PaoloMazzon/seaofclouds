#version 450
#extension GL_ARB_separate_shader_objects : enable
#extension GL_EXT_scalar_block_layout : enable
#extension GL_EXT_nonuniform_qualifier : enable
 
// VK2D provided variables
layout(push_constant) uniform PushBuffer {
    int cameraIndex;
    uint textureIndex;
    vec4 texturePos;
    vec4 colour;
    mat4 model;
} push;
 
layout(set = 0, binding = 0) uniform UniformBufferObject {
    mat4 viewproj[10];
} ubo;
 
layout(set = 1, binding = 1) uniform sampler texSampler;
layout(set = 2, binding = 2) uniform texture2D tex[];
 
// Input from the vertex shader
layout(location = 1) in vec2 fragTexCoord;
layout(location = 2) in vec4 fragColour;
 
// Output of the fragment shader
layout(location = 0) out vec4 outColor;

void main() {
    vec4 colour = texture(sampler2D(tex[push.textureIndex], texSampler), fragTexCoord);
    vec4 colourUp = texture(sampler2D(tex[push.textureIndex], texSampler), vec2(fragTexCoord.x, fragTexCoord.y - 1));
    vec4 colourDown = texture(sampler2D(tex[push.textureIndex], texSampler), vec2(fragTexCoord.x, fragTexCoord.y + 1));
    vec4 colourLeft = texture(sampler2D(tex[push.textureIndex], texSampler), vec2(fragTexCoord.x - 1, fragTexCoord.y));
    vec4 colourRight = texture(sampler2D(tex[push.textureIndex], texSampler), vec2(fragTexCoord.x + 1, fragTexCoord.y));
    if (colour.a == 0 && (colourDown.a != 0 || colourUp.a != 0 || colourLeft.a != 0 || colourRight.a != 0)) {
        outColor = vec4(0, 0.4, 0.7, 1);
    } else {
        outColor = vec4(0, 0, 0, 0);
    }
}