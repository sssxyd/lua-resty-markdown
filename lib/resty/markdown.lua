local document = require "resty.hoedown.document"
local html     = require "resty.hoedown.html"
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
_M.htmlToc = function(markdown, max_nesting, toc_nesting, smartypants)
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

return _M