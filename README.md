# SHDR

C program that renders [ShaderToy](https://shadertoy.com) shaders natively. Can run on a Raspberry PI without a desktop environment/window manager.

## Preparation

First, install SDL2 and GLEW for your platform. 

### On Debian based systems
```
sudo apt update && sudo apt install libsdl2-dev libglew-dev
```

### On OSX
```
sudo brew install sdl2 glew
```

### On Raspian (headless via DRM/KMS)
```
sudo apt install libegl1-mesa-dev libsdl2-dev build-essential libxmu-dev libxi-dev libgl-dev
git clone https://github.com/nigels-com/glew.git
cd glew/auto
make
cd ..
make SYSTEM=linux-egl
sudo make install
```

### Windows

Haven't tried this yet so it probably doesn't work even though the makefile has some config options for it.

## Installing

Just run:
```
make
sudo make install
```

## Running

You can run one of the examples like so:

```
shdr shaders/checkerboard.glsl
```

 
## Example Shader Credits

 - `shaders/checkerboard.glsl` by me
 - `shaders/lambert.glsl` by me
 - `shaders/ray-marching.glsl` by me
 - `shaders/truchet.glsl` by me
 - `shaders/rug.glsl` by [jarble](https://www.shadertoy.com/user/jarble)
 - `shaders/maze.glsl` by [santreal](https://www.shadertoy.com/user/santreal)
 - `shaders/fuji.glsl` by [kaiware007](https://www.shadertoy.com/user/kaiware007)


## Notes

Right now not all the uniforms that are available on [ShaderToy](https://shadertoy.com) are implemented. This might prevent some things from working. Music and multi channel won't work at the moment. Here are the available uniforms:

- `uniform vec2 iResolution` the width and height of the display surface
- `uniform float iTime` the number of seconds that have passed since the program started

