#version 300 es
precision mediump float;

in vec2 v_texcoord;
uniform sampler2D tex;
uniform float u_brightness;
uniform float u_contrast;

out vec4 fragColor;

const float DEFAULT_BRIGHTNESS = 0.08;
const float DEFAULT_CONTRAST   = 1.15;

void main() {
    vec4 col = texture(tex, v_texcoord);

    float brightness = (abs(u_brightness) < 1e-5) ? DEFAULT_BRIGHTNESS : u_brightness;
    float contrast   = (abs(u_contrast)   < 1e-5) ? DEFAULT_CONTRAST   : u_contrast;

    col.rgb = (col.rgb - 0.5) * contrast + 0.5 + brightness;

    fragColor = clamp(col, 0.0, 1.0);
}
