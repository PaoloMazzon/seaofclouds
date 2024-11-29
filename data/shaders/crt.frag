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
    int cell = int(fragTexCoord.x);
    const float bleed = 0.3;

    // Simulate RGB cells
    if (cell % 3 == 0) { // Red component
        outColor = vec4(colour.r, colour.g * bleed, colour.b * bleed, colour.a);
    } else if (cell % 3 == 1) { // Green component
        outColor = vec4(colour.r * bleed, colour.g, colour.b * bleed, colour.a);
    } else if (cell % 3 == 2) { // Blue component
        outColor = vec4(colour.r * bleed, colour.g * bleed, colour.b, colour.a);
    }

    // Scanlines
    if (int(fragTexCoord.y) % 3 == 0) {
        outColor.rgb *= 0.8;
    }
}