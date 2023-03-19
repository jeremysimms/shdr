#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <time.h>
#include <SDL2/SDL.h>
#include <GL/glew.h>
#include <SDL2/SDL_opengl.h>

int w = 640;
int h = 480;

GLchar* read_shader_file(const char* filename)
{
    char* buffer = NULL;
    long length;
    FILE* file = fopen(filename, "rb");

    if (file)
    {
        fseek(file, 0, SEEK_END);
        length = ftell(file);
        fseek(file, 0, SEEK_SET);
        buffer = (char*)malloc(length + 1);
        if (buffer)
        {
            fread(buffer, 1, length, file);
            buffer[length] = '\0';
        }
        fclose(file);
    }
    return buffer;
}

void print_shader_info_log(GLuint id) {
    char buffer[512];
    glGetShaderInfoLog(id, 512, NULL, buffer);
    printf("%s", buffer);
}

void print_shader_program_log(GLuint id) {
    char buffer[512];
    glGetProgramInfoLog(id, 512, NULL, buffer);
    printf("%s", buffer);
}

int main(int argc, char* args[])
{
    if(argc == 1) {
        printf("No fragment shader provided.");
        return EXIT_FAILURE;
    }
    SDL_Window *window;
    SDL_GLContext glContext;

    // Initialize SDL
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        printf("Failed to initialize SDL\n");
        return EXIT_FAILURE;
    }

    // Set OpenGL version to 3.2
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 2);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 0);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_ES);
    Uint32 windowFlags = SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN | SDL_WINDOW_FULLSCREEN;
    // Create window
    window = SDL_CreateWindow("SHDR",
        SDL_WINDOWPOS_UNDEFINED,
        SDL_WINDOWPOS_UNDEFINED,
        w, h,
         windowFlags);
    SDL_ShowCursor(0);
    if (!window)
    {
        printf("Failed to create SDL window: %s\n", SDL_GetError());
        SDL_Quit();
        return EXIT_FAILURE;
    }
    //Create OpenGL context
    glContext = SDL_GL_CreateContext(window);
    if(glContext == NULL) {
        printf("OpenGL context could not be created! SDL Error: %s\n", SDL_GetError());
        SDL_Quit();
        return EXIT_FAILURE;
    }
    if( SDL_GL_SetSwapInterval( 1 ) < 0 )
    {
        printf( "Warning: Unable to set VSync! SDL Error: %s\n", SDL_GetError() );
        SDL_Quit();
        return EXIT_FAILURE;
    }

    // Initialize GLEW
    glewExperimental = GL_TRUE; 
    GLenum glewStatus = glewInit();
    if (glewStatus != GLEW_OK && glewStatus != GLEW_ERROR_NO_GLX_DISPLAY)
    {
        printf("Failed to initialize GLEW: %i\n", glewStatus);
        SDL_GL_DeleteContext(glContext);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return EXIT_FAILURE;
    }

    // Load vertex shader
    GLuint shaderProgram = glCreateProgram();
    const GLchar* vertexSource[] =
	{
		"#version 100\nattribute vec2 aPos; void main() { gl_Position = vec4( aPos.x, aPos.y, 0, 1 ); }"
	};
    if(vertexSource == NULL) {
        SDL_GL_DeleteContext(glContext);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return EXIT_FAILURE;
    }
    GLuint vertexShader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertexShader, 1, &vertexSource, NULL);
    glCompileShader(vertexShader);
    // Check for vertex shader compilation errors
    GLint status;
    glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &status);
    if (status != GL_TRUE)
    {
        printf("Failed to compile vertex shader\n");
        print_shader_info_log(vertexShader);
        SDL_GL_DeleteContext(glContext);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return EXIT_FAILURE;
    }
    glAttachShader(shaderProgram, vertexShader);

    // Load fragment shader
    GLchar* fragmentSource = read_shader_file(args[1]);
    GLuint fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragmentShader, 1, &fragmentSource, NULL);
    glCompileShader(fragmentShader);
    // Check for fragment shader compilation errors
    glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, &status);
    if (status != GL_TRUE)
    {
        printf("Failed to compile fragment shader\n");
        print_shader_info_log(fragmentShader);
        SDL_GL_DeleteContext(glContext);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return EXIT_FAILURE;
    }
    glAttachShader(shaderProgram, fragmentShader);
    glLinkProgram(shaderProgram);
    GLint programSuccess = GL_TRUE;
    glGetProgramiv(shaderProgram, GL_LINK_STATUS, &programSuccess);
    if(programSuccess != GL_TRUE) {
        printf("Error linking shader!\n");
        print_shader_program_log(shaderProgram);
        SDL_GL_DeleteContext(glContext);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return EXIT_FAILURE;
    }
    GLint vertLocation = glGetAttribLocation(shaderProgram, "aPos");
    if(vertLocation == -1) {
        printf("Bad shader variable name! Vert:%i \n", vertLocation);
        SDL_GL_DeleteContext(glContext);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return EXIT_FAILURE;
    }
    GLuint vaoId = 0;
    glGenVertexArrays(1, &vaoId);
    glBindVertexArray(vaoId);
    glClearColor(0.f, 0.f, 0.f, 1.f);
    GLfloat vertexData[] =
    {
        -1.f, -1.f,
        1.f, -1.f,
        1.f,  1.0f,
        -1.f,  1.0f
    };
    GLuint indexData[] = { 0, 1, 2, 3 };
    GLuint gVBO = 0;
    GLuint gIBO = 0;
    //Create VBO
    glGenBuffers( 1, &gVBO );
    glBindBuffer( GL_ARRAY_BUFFER, gVBO );
    glBufferData( GL_ARRAY_BUFFER, 2 * 4 * sizeof(GLfloat), vertexData, GL_STATIC_DRAW );

    //Create IBO
    glGenBuffers( 1, &gIBO );
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, gIBO );
    glBufferData( GL_ELEMENT_ARRAY_BUFFER, 4 * sizeof(GLuint), indexData, GL_STATIC_DRAW );
    bool quit = false;
    SDL_Event e;
    SDL_DisplayMode DM;
    SDL_GetCurrentDisplayMode(0, &DM);
    while(!quit) {
        while( SDL_PollEvent( &e ) != 0 ) {
            if( e.type == SDL_QUIT || e.type == SDL_KEYDOWN && e.key.keysym.sym == SDLK_ESCAPE) {
                quit = true;
            }
        }
        glClear(GL_COLOR_BUFFER_BIT);
        glUseProgram( shaderProgram );
        glEnableVertexAttribArray(vertLocation);
        glBindBuffer( GL_ARRAY_BUFFER, gVBO );
        GLint t = glGetUniformLocation(shaderProgram, "iTime");
        GLint resolution = glGetUniformLocation(shaderProgram, "iResolution");
        glUniform1f(t, (float)SDL_GetTicks()/1000.);
        glUniform2i(t, w, h);
        glVertexAttribPointer( vertLocation, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(GLfloat), NULL );
        glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, gIBO );
        glDrawElements( GL_TRIANGLE_FAN, 4, GL_UNSIGNED_INT, NULL );
        glDisableVertexAttribArray( vertLocation );
        glUseProgram( NULL );
        SDL_GL_SwapWindow( window );
    }
    glDeleteProgram(shaderProgram);
    free(fragmentSource);
    SDL_DestroyWindow( window );
	window = NULL;
    SDL_Quit();
    return EXIT_SUCCESS;
}