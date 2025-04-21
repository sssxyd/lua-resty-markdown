# lua-resty-markdown
用[hoedown](https://github.com/hoedown/hoedown)将markdown转为html  
本项目集成[hoedown](https://github.com/hoedown/hoedown) 和 [lua-resty-hoedown](https://github.com/bungle/lua-resty-hoedown), 封装为一个Module，并提供标准接口

# 安装
因本项目包含C代码，不能用OPM命令安装，需编译安装(无任何依赖)
1. 安装[openresty](https://openresty.org/en/installation.html)
2. `git clone https://github.com/sssxyd/lua-resty-markdown.git`
3. `cd lua-resty-markdown`
4. `make && make install`
5. `openresty -s reload`
6. 验证安装：`resty -e "require 'resty.markdown'"`

# Usage


# API
请查看 [markdown.lua](lib/resty/markdown.lua)