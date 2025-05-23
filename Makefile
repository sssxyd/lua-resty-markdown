# Variables
CC = gcc
OPENRESTY_HOME ?= /usr/local/openresty
LUA_LIB_MAIN = $(OPENRESTY_HOME)/lualib/resty/markdown.lua
LUA_LIB_DIR = $(OPENRESTY_HOME)/lualib/resty/hoedown
LUA_SO_DIR = $(OPENRESTY_HOME)/lualib
CFLAGS = -O2 -fPIC -I./src
LDFLAGS = -shared
TARGET = libhoedown.so
SRC = $(wildcard src/*.c)
INSTALL = install

# Declare phony targets
.PHONY: all install clean

# Default target
all: $(TARGET)

# Compile the C code into a shared library
$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

# Install the Lua and C files
install:
	$(INSTALL) -d $(LUA_LIB_DIR)
	$(INSTALL) -m 644 lib/resty/markdown.lua $(LUA_LIB_MAIN)
	$(INSTALL) -m 644 lib/resty/hoedown/*.lua $(LUA_LIB_DIR)
	sed -i 's|return ffi_load "hoedown"|return ffi_load "$(OPENRESTY_HOME)/lualib/libhoedown.so"|' $(LUA_LIB_DIR)/library.lua
	$(INSTALL) -m 755 $(TARGET) $(LUA_SO_DIR)
	@echo "Installed $(TARGET) to $(LUA_SO_DIR)"
	@echo "Installed Lua files to $(LUA_LIB_MAIN) and $(LUA_LIB_DIR)"
	@echo "You should run 'openresty -s reload' to apply the changes."
	@echo "Installation complete."

# Clean up build artifacts
clean:
	rm -f $(LUA_LIB_MAIN)
	rm -rf $(LUA_LIB_DIR)
	rm -f $(LUA_SO_DIR)/$(TARGET)
	rm -f src/*.o
	rm -f $(TARGET)