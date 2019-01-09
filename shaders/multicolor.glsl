#ifdef GL_ES
  precision mediump float;
  precision mediump int;
#endif

uniform float time;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
  // Normalized pixel coordinates (from 0 to 1)
  vec2 uv = screen_coords/love_ScreenSize.xy;

  // Time varying pixel color
  vec3 col = 0.5 + 0.5 * cos(time / 8.0 + vec3(0.0, 2.0, 4.0)); // vec3 col = 0.5 + 0.5 * cos(time / 2.0 + uv.xyx + vec3(0.0, 2.0, 4.0));

  // Output to screen
  vec4 texturecolor = Texel(texture, texture_coords);
  return texturecolor * vec4(col, 1.0) * color;
}
