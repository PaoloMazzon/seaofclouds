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

layout(set = 3, binding = 3) uniform UserData {
    vec2 resolution;
} userData;

// Input from the vertex shader
layout(location = 1) in vec2 fragTexCoord;
layout(location = 2) in vec4 fragColour;
 
// Output of the fragment shader
layout(location = 0) out vec4 outColor;

void main() {
    vec2 res = userData.resolution;
    vec2 uv = fragTexCoord / res;
    
    // Slight curvature
    vec2 curvedUV = uv * 2.0 - 1.0;
    curvedUV *= 1.05 + 0.05 * length(curvedUV);
    uv = curvedUV * 0.5 + 0.5;

    // Prevent sampling outside valid range
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        outColor = vec4(0.0);
        return;
    }

    vec4 colour = texture(sampler2D(tex[push.textureIndex], texSampler), uv * res);

    // Scanlines
    float scanline = sin(fragTexCoord.y * 3.14159) * 0.1;
    colour *= 1.0 - scanline;

    // Chromatic aberration
    float aberration = 1.25;
    float r = texture(sampler2D(tex[push.textureIndex], texSampler), (uv * res) + vec2(aberration, 0.0)).r;
    float b = texture(sampler2D(tex[push.textureIndex], texSampler), (uv * res) - vec2(aberration, 0.0)).b;
    
    outColor = vec4(r, colour.g, b, 1.0);
}