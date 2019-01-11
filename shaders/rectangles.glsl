uniform float time;

const int nRect = 4;
const int rep = 4;
float divs[nRect*rep];

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
  float vel = time/2;
  vec4 varCol = vec4(0.5 + 0.5 * cos(time / 8.0 + vec3(0.0, 2.0, 4.0)), 1.0);
  vec2 uv = screen_coords/love_ScreenSize.xy;
  vec3 colors[nRect];
  colors[0] = vec3(.7, .7, .7);
  colors[1] = vec3(.6, .6, .6);
  colors[2] = vec3(.5, .5, .5);
  colors[3] = vec3(.6, .6, .6);

  int lDiv = 0;
  int rDiv = 0;
  for (int i = 0; i < nRect*rep; i++) {
   	divs[i] = (float(i)/float(nRect*rep) + vel) - floor(float(i)/float(nRect*rep) + vel);
    if(divs[rDiv] < divs[i]) rDiv = i; else rDiv = rDiv;
    if(divs[lDiv] > divs[i]) lDiv = i; else lDiv = lDiv;
  }

  for (int i = 0; i < nRect*rep; i++) {
    if (i == rDiv) {
      float div1 = divs[rDiv];
      float div2 = divs[lDiv];
        if ((uv.y > div1) || (uv.y < div2))
        	return vec4(colors[int(mod(i, nRect))], (cos(time/2)*2+2)/16 + 0.25) * color * varCol;
    } else {
      	float div1 = divs[i];
      	float div2 = i+1 == nRect*rep ? divs[0] : divs[i+1];
        if ((uv.y > div1) && (uv.y < div2))
      		return vec4(colors[int(mod(i, nRect))], (cos(time/2)*2+2)/16 + 0.25) * color * varCol;
    }
  }
}
