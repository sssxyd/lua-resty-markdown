local document = require "resty.hoedown.document"
local html     = require "resty.hoedown.html"
local ver  = require "resty.hoedown.version"
local type         = type

local _M = {}

--- Converts Markdown source text to HTML.
-- @param source (string) Markdown source text.
-- @param opts (table) Optional parameter table, containing the following fields:
--   - renderer (string|function): Specifies the renderer.
--       - If it is a string:
--           - "html.toc": Use the renderer that generates a Table of Contents.
--           - Other values: Use the default HTML renderer.
--       - If it is a function: Custom renderer, the function receives `opts` as a parameter.
--       - If not specified, the default HTML renderer is used.
--   - extensions (table): List of enabled extensions (optional).
--   - max_nesting (number): Maximum nesting depth (optional).
--   - smartypants (boolean): Whether to enable Smartypants functionality (optional).
--       - Smartypants converts ordinary punctuation into typographically correct symbols, such as:
--         - Converting " to curly quotes (“”).
--         - Converting -- to an em dash (—).
--   - flags (number): Renderer flags (optional).
--   - nesting (number): Renderer nesting depth (optional).
-- @return (string) The converted HTML string.
_M.hoedown = function(source, opts)
    local renderer, extensions, max_nesting, smartypants
    if type(opts) == "table" then
        extensions, max_nesting, smartypants = opts.extensions, opts.max_nesting, opts.smartypants
        local t = type(opts.renderer)
        if t == "string"  then
            if opts.renderer == "html.toc" then
                renderer = html.toc.new(opts.nesting)
            else
                renderer = html.new(opts.flags, opts.nesting)
            end
        elseif t == "function" then
            renderer = opts.renderer(opts)
        else
            renderer = html.new(opts.flags, opts.nesting)
        end
    else
        renderer = html.new()
    end
    if smartypants then
        return html.smartypants(document.new(renderer, extensions, max_nesting):render(source))
    else
        return document.new(renderer, extensions, max_nesting):render(source)
    end
end

--- Converts Markdown source text to HTML.
-- @param markdown (string) Markdown source text.
-- @param max_nesting (number) Maximum nesting depth (optional, default is 16).
-- @param smartypants (boolean) Whether to enable Smartypants functionality (optional, default is true).
--       - Smartypants converts ordinary punctuation into typographically correct symbols, such as:
--         - Converting " to curly quotes (“”).
--         - Converting -- to an em dash (—).
-- @return (string) The converted HTML string.
_M.html = function(markdown, max_nesting, smartypants)
    -- Enable all extensions by default
    local extensions = {
        "tables",               -- Table extension
        "fenced_code",          -- Support for fenced code blocks
        "footnotes",            -- Support for footnotes
        "autolink",             -- Automatic linking
        "strikethrough",        -- Strikethrough
        "underline",            -- Underline
        "highlight",            -- Highlight
        "quote",                -- Quote
        "superscript",          -- Superscript
        "math",                 -- Math formulas
        "no_intra_emphasis",    -- Disable intra-word emphasis
        "space_headers",        -- Space headers
        "math_explicit",        -- Explicit math formulas
        "disable_indented_code" -- Disable indented code blocks
    }

    -- Set renderer flags
    local flags = {
        "hard_wrap",    -- Convert line breaks to <br> tags
        "use_xhtml",    -- Use XHTML syntax
    }

    if smartypants == nil then
        smartypants = true
    end

    return _M.hoedown(markdown, {
        renderer = "html",
        flags = flags,
        max_nesting = max_nesting or 16,
        extensions = extensions,
        smartypants = smartypants
    })
end

--- Converts Markdown source text to an HTML Table of Contents.
-- @param markdown (string) Markdown source text.
-- @param max_nesting (number) Maximum nesting depth (optional, default is 16).
-- @param toc_nesting (number) TOC nesting depth (optional, default is 6).
-- @param smartypants (boolean) Whether to enable Smartypants functionality (optional, default is true).
--       - Smartypants converts ordinary punctuation into typographically correct symbols, such as:
--         - Converting " to curly quotes (“”).
--         - Converting -- to an em dash (—).
-- @return (string) The converted HTML TOC string.
_M.toc = function(markdown, max_nesting, toc_nesting, smartypants)
    -- Enable all extensions by default
    local extensions = {
        "tables",               -- Table extension
        "fenced_code",          -- Support for fenced code blocks
        "footnotes",            -- Support for footnotes
        "autolink",             -- Automatic linking
        "strikethrough",        -- Strikethrough
        "underline",            -- Underline
        "highlight",            -- Highlight
        "quote",                -- Quote
        "superscript",          -- Superscript
        "math",                 -- Math formulas
        "no_intra_emphasis",    -- Disable intra-word emphasis
        "space_headers",        -- Space headers
        "math_explicit",        -- Explicit math formulas
        "disable_indented_code" -- Disable indented code blocks
    }

    -- Set renderer flags, enable HTML escaping
    local flags = {
        "hard_wrap",    -- Convert line breaks to <br> tags
        "use_xhtml",    -- Use XHTML syntax
    }
    
    if smartypants == nil then
        smartypants = true
    end

    return _M.hoedown(markdown, {
        renderer = "html.toc",
        flags = flags,
        nesting = toc_nesting or 6,
        max_nesting = max_nesting or 16,
        extensions = extensions,
        smartypants = smartypants
    })
end

--- Renders Markdown content to HTML and returns a complete HTML document.
-- @param markdown (string) Markdown content.
-- @param title (string) Title of the HTML document (optional, default is "markdown").
-- @param stylesheet/css (string) URL of the CSS stylesheet (optional, default is a GitHub Markdown CSS).
-- @param max_nesting (number) Maximum nesting depth (optional, default is 16).
-- @param smartypants (boolean) Whether to enable Smartypants functionality (optional, default is true).
--       - Smartypants converts ordinary punctuation into typographically correct symbols, such as:
--         - Converting " to curly quotes (“”).
--         - Converting -- to an em dash (—).
-- @return (string) The complete HTML document.
_M.render = function()
    local uri = ngx.var.uri
    local match = ngx.re.match(uri, "([^/]+)%.md$", "jo")
    local filename = (match and match[1]) or "markdown"
    if filename:find("[/\\]") then
        filename = "markdown"
        ngx.log(ngx.WARN, "invalid uri: ", uri)
    end

    local args = ngx.req.get_uri_args()
    local title = args.title or ngx.unescape_uri(filename):gsub("-", " ")
    local stylesheet = args.stylesheet or args.css or "https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/5.8.1/github-markdown.min.css"
    local max_nesting = args.max_nesting or 16
    local smartypants = args.smartypants or true

    local ok, md_html = pcall(_M.html, ngx.arg[1], max_nesting, smartypants)
    if not ok then
        ngx.log(ngx.ERR, "Markdown render failed: ", ngx.arg[1])
        md_html = "<h1>Render Failed!</h1>"
    end

    local html_template = [[
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <meta name="apple-mobile-web-app-capable" content="yes">
            <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
            <title>%s</title>
            <link rel="stylesheet" href="%s">
        </head>
        <body class="markdown-body">
            <div id="content">%s</div>
        </body>
        </html>
    ]]
    return string.format(html_template, title, stylesheet, md_html)
end

--- return hoedown version_number
-- @return (string) The version number of the hoedown library.
_M.version = function ()
    return ver.version
end

return _M