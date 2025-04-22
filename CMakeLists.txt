cmake_minimum_required(VERSION 3.10)
project(lua_resty_markdown)

# 设置C标准
set(CMAKE_C_STANDARD 99)

# 查找 OpenResty 的安装位置
find_path(OPENRESTY_HOME
    NAMES nginx/conf/nginx.conf
    PATHS /usr/local/openresty /opt/openresty /data/openresty
    DOC "Path to OpenResty installation"
)

if(NOT OPENRESTY_HOME)
    message(FATAL_ERROR "OpenResty installation not found. Please specify OPENRESTY_HOME manually using -DOPENRESTY_HOME=<path>.")
endif()

# 设置变量
set(LUA_LIB_DIR "${OPENRESTY_HOME}/lualib/resty")
set(LUA_SO_DIR "${OPENRESTY_HOME}/lualib")
set(TARGET "hoedown")

# 源文件
file(GLOB SRC "src/*.c")

# 编译选项
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O2 -fPIC")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -shared")

# 生成共享库
add_library(${TARGET} SHARED ${SRC})

# 安装目标
COMMAND ${CMAKE_COMMAND} -E echo "Installing ${TARGET} to ${LUA_SO_DIR}"
install(TARGETS ${TARGET} DESTINATION ${LUA_SO_DIR})
COMMAND ${CMAKE_COMMAND} -E echo "Installing Lua module to ${LUA_LIB_DIR}"
install(FILES lib/resty/markdown.lua DESTINATION ${LUA_LIB_DIR})
install(DIRECTORY lib/resty/hoedown DESTINATION ${LUA_LIB_DIR})

add_custom_target(uninstall
    COMMAND ${CMAKE_COMMAND} -E echo "Removing ${LUA_LIB_DIR}/markdown.lua"
    COMMAND ${CMAKE_COMMAND} -E remove -f ${LUA_LIB_DIR}/markdown.lua
    COMMAND ${CMAKE_COMMAND} -E echo "Removing directory ${LUA_LIB_DIR}/hoedown"
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${LUA_LIB_DIR}/hoedown
    COMMAND ${CMAKE_COMMAND} -E echo "Removing ${LUA_SO_DIR}/lib${TARGET}.so"
    COMMAND ${CMAKE_COMMAND} -E remove -f ${LUA_SO_DIR}/lib${TARGET}.so
    COMMENT "Uninstalling Lua modules and shared library"
)