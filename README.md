# SHDR

C program that renders OpenGL fragment shaders onto a full screen quad.


## Installing

First, install SDL2 and GLEW for your platform. Then run the make file. 
If you're on mac or windows just add `mac` or `windows` as an argument to the make command

## Running

Execute `bin/shdr` after it finishes building and pass it a GLSL shader with the output fragment color variable named "outColor".


## Available uniforms

Right now you can leverage the following:

- `uniform vec2 iResolution` the width and height of the display surface
- `uniform float iTime` the number of seconds that have passed since the program started

