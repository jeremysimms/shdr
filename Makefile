UNAME=$(shell uname)
CC=gcc
SRC_DIR=src
BIN_DIR=bin
OBJ_DIR=obj
INC_DIR=include
SDL_CONFIG=sdl2-config
SRC=$(wildcard $(SRC_DIR)/*.c)
OBJS=$(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SRC))
OUT=shdr
CFLAGS=$(shell $(SDL_CONFIG) --cflags) -lm -std=gnu99
INC=-I$(INC_DIR)/
LIBS=$(shell $(SDL_CONFIG) --libs)
OTHER_LIB=-lGLEW
MAC_ARGS = -framework OpenGL

ifeq ($(OS), Darwin)
	DEBUG=-g
else 
	DEBUG=-ggdb
endif
debug: CFLAGS += $(DEBUG)
debug: CFLAGS += -DDEBUG_TEST
windows: CC=x86_64-w64-mingw32-gcc 
windows: SDL_CONFIG=$(shell echo $$WINDOWS_SDL_CONFIG_LOCATION)
windows: CFLAGS += --std=c99
mac: INC += -I/usr/local/include -I/opt/homebrew/Cellar/glew/2.2.0_1/include -I/opt/homebrew/Cellar/sdl2/2.26.4/include

all: $(OBJS)
	$(CC) $^ $(CFLAGS) $(LIBS) $(OTHER_LIB) -o $(addprefix $(BIN_DIR)/,$(OUT))

$(OBJ_DIR)/%.o : $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) $(INC) -c -o $@ $<

debug: $(OBJS)
	$(CC) $^ $(CFLAGS) $(LIBS) $(OTHER_LIB) -o $(addprefix $(BIN_DIR)/,$(OUT)_debug)

windows: $(OBJS)
	$(CC) $^ $(CFLAGS) $(LIBS) $(OTHER_LIB) -o $(addprefix $(BIN_DIR)/,$(OUT).exe)

mac: $(OBJS)
	$(CC) $^ $(CFLAGS) $(LIBS) $(OTHER_LIB) -o $(addprefix $(BIN_DIR)/,$(OUT)) $(MAC_ARGS)

clean:
	rm -rf $(BIN_DIR)/*
	rm -f $(OBJ_DIR)/*.o
