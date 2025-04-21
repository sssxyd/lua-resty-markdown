cmake_minimum_required(VERSION 3.10)
project(lua_resty_markdown)

# 设置C标准
set(CMAKE_C_STANDARD 99)

# 设置变量
set(OPENRESTY_HOME "/usr/local/openresty" CACHE PATH "Path to OpenResty installation")
set(LUA_LIB_MAIN "${OPENRESTY_HOME}/lualib/resty/markdown.lua")
set(LUA_LIB_DIR "${OPENRESTY_HOME}/lualib/resty/hoedown")
set(LUA_SO_DIR "${OPENRESTY_HOME}/lualib")
set(TARGET "libhoedown.so")

# 源文件
file(GLOB SRC "src/*.c")

# 编译选项
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O2 -fPIC")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -shared")

# 生成共享库
add_library(${TARGET} SHARED ${SRC})

# 安装目标
install(TARGETS ${TARGET} DESTINATION ${LUA_SO_DIR})
install(FILES lib/resty/markdown.lua DESTINATION ${LUA_LIB_MAIN})
install(DIRECTORY lib/resty/hoedown/ DESTINATION ${LUA_LIB_DIR})

# 自定义清理目标
add_custom_target(clean
    COMMAND ${CMAKE_COMMAND} -E remove -f ${LUA_LIB_MAIN}
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${LUA_LIB_DIR}
    COMMAND ${CMAKE_COMMAND} -E remove -f ${LUA_SO_DIR}/${TARGET}
    COMMAND ${CMAKE_COMMAND} -E remove -f src/*.o
    COMMENT "Cleaning up build artifacts"
)