# Variables
CC = gcc
OPENRESTY_HOME ?= /usr/local/openresty
LUA_LIB_DIR = $(OPENRESTY_HOME)/lualib/resty/markdown
LUA_SO_DIR = $(OPENRESTY_HOME)/lualib
CFLAGS = -O2 -fPIC -I./src
LDFLAGS = -shared
TARGET = hoedown.so
SRC = $(wildcard src/*.c)
INSTALL = install

# Default target
all: $(TARGET)

# Compile the C code into a shared library
$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

# Install the Lua and C files
install:
	$(INSTALL) -d $(LUA_LIB_DIR)
	$(INSTALL) -m 644 lib/resty/markdown/*.lua $(LUA_LIB_DIR)
	$(INSTALL) -m 755 $(TARGET) $(LUA_SO_DIR)

# Clean up build artifacts
clean:
	rm -f $(TARGET) *.o