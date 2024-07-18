module HTMLBook

using TOML
using CommonMark
using IOCapture
using FileWatching

const HTML_TEMPLATE = """<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta charset="UTF-8" />
        <title>TITLE</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.9.0/build/styles/default.min.css"/>
        <link rel="stylesheet" href="STYLESHEET">
        <script src="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.9.0/build/highlight.min.js"></script>
        <script src="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.9.0/build/languages/julia.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/katex@0.16.10/dist/katex.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/katex@0.16.10/dist/contrib/auto-render.min.js"></script>
        <script>
        document.addEventListener("DOMContentLoaded", function () {
            renderMathInElement(document.body, {
            delimiters: [
                { left: "\\(", right: "\\)", display: false },
                { left: "\\[", right: "\\]", display: true },
            ],
            throwOnError: false,
            output: "mathml",
            });
            hljs.highlightAll();
        });
        </script>
    </head>
    <body data-type="TYPE">
BODY
    </body>
</html>
"""

function Base.show(io::IO, ::MIME"text/html", val::Any)
    write(io, """<div data-type="programresult">\n""")
    for line in split(string(val), "\n")
        write(io, "    ", line, "\n")
    end
    write(io, "</div>\n")
end

function _tohtml(io::IOBuffer, file::String)
    if !isfile(file)
        error("File does not exist!")
    end
    name, ext = splitext(basename(file))
    if ext != ".md"
        error("File has no .md extension!")
    end
    parser = Parser()
    enable!(parser, FootnoteRule())
    enable!(parser, TypographyRule())
    enable!(parser, AdmonitionRule())
    enable!(parser, MathRule())
    enable!(parser, TableRule())
    enable!(parser, RawContentRule())
    enable!(parser, AttributeRule())
    enable!(parser, CitationRule())
    ast = open(parser, file)
    level = 0
    toc = IOBuffer()
    writer = CommonMark.Writer(CommonMark.HTML(), io)
    for (node, entering) in ast
        level = _html(io, node.t, entering, node.literal, node.meta, level)
        #CommonMark.write_html(node.t, writer, node, entering)
    end
    for l in level-1:-1:0
        println(io, " "^4l, "</section>")
    end
    return String(take!(toc))
end

function _html(io::IOBuffer, _::Union{CommonMark.Attributes,CommonMark.Document}, entering::Bool, str::String, attributes::Dict{String,Any}, level::Int64)
    return level
end

function _html(io::IOBuffer, type::Any, entering::Bool, str::String, attributes::Dict{String,Any}, level::Int64)
    if entering
        println(io)
        println(io, entering, " ", type, " ", str, " ", attributes)
    else
        #println(io, entering, " ", type, " ", str, " ", attributes)
    end
    return level
end

function _html(io::IOBuffer, _::CommonMark.Paragraph, entering::Bool, str::String, attributes::Dict{String,Any}, level::Int64)
    if entering
        print(io, " "^4level)
        print(io, "<p>")
    else
        println(io, "</p>")
    end
    return level
end

function _html(io::IOBuffer, _::CommonMark.Strong, entering::Bool, str::String, attributes::Dict{String,Any}, level::Int64)
    if entering
        print(io, "<b>")
    else
        print(io, "</b>")
    end
    return level
end

function _html(io::IOBuffer, _::CommonMark.Emph, entering::Bool, str::String, attributes::Dict{String,Any}, level::Int64)
    if entering
        print(io, "<i>")
    else
        print(io, "</i>")
    end
    return level
end

function _html(io::IOBuffer, link::CommonMark.Link, entering::Bool, str::String, attributes::Dict{String,Any}, level::Int64)
    if entering
        print(io, """<a href="$(link.destination)">""")
    else
        print(io, "</a>")
    end
    return level
end

function _html(io::IOBuffer, _::CommonMark.DisplayMath, entering::Bool, str::String, attributes::Dict{String,Any}, level::Int64)
    if entering
        print(io, " "^4level)
        println(io, """<div class="math-tex" data-type="equation">""")
        print(io, " "^4level)
        println(io, "\\[")
        level += 1
        for line in split(str, "\n")
            print(io, " "^4level)
            println(io, line)
        end
        level -= 1
        print(io, " "^4level)
        println(io, "\\]")
        print(io, " "^4level)
        println(io, "</div>")
    else
        nothing
    end
    return level
end

function _html(io::IOBuffer, _::CommonMark.Math, entering::Bool, str::String, attributes::Dict{String,Any}, level::Int64)
    if entering
        print(io, """<span class="math-tex" data-type="tex">\\(""", str, "\\)</span>")
    else
        nothing
    end
    return level
end

function _html(io::IOBuffer, _::CommonMark.SoftBreak, entering::Bool, str::String, attributes::Dict{String,Any}, level::Int64)
    if entering
        print(io, "<br/>")
    else
        nothing
    end
    return level
end

function _html(io::IOBuffer, type::CommonMark.Heading, entering::Bool, str::String, attributes::Dict{String,Any}, level::Int64)
    tag = if type.level == 1
        "h1"
    else
        "h$(type.level-1)"
    end
    l = level
    if entering
        id = if type.level == 1
            println(io, """<section data-type="chapter">""")
            get(attributes, "id", gensym("chapter"))
        else
            if type.level == l
                l -= 1
                print(io, " "^4l)
                println(io, "</section>")
            end
            print(io, " "^4l)
            println(io, """<section data-type="sect$(type.level-1)">""")
            get(attributes, "id", gensym("sect$(type.level-1)"))
        end
        l += 1
        print(io, " "^4l)
        print(io, """<$tag id=$id>""")
    else
        println(io, "</$tag>")
    end
    return l
end

function _html(io::IOBuffer, type::CommonMark.Admonition, entering::Bool, str::String, attributes::Dict{String,Any}, level::Int64)
    l = level
    if entering
        id = get(attributes, "id", gensym("$(type.category)"))
        print(io, " "^4l)
        println(io, """<div data-type="$(type.category)">""")
        l += 1
        if lowercase(type.category) !== lowercase(type.title)
            print(io, " "^4l)
            println(io, """<h1 id=$id">""", type.title, "</h1>")
        end
    else
        l -= 1
        print(io, " "^4l)
        println(io, "</div>")
    end
    return l
end

const MODULES = Dict{String,Module}()

function _html(io::IOBuffer, type::CommonMark.CodeBlock, entering::Bool, str::String, attributes::Dict{String,Any}, level::Int64)
    l = level
    if entering
        language = type.info
        if get(attributes, "display", "true") === "true"
            print(io, " "^4l)
            println(io, """<pre data-type="programlisting" data-code-language="$language">""")
            l += 1
            print(io, " "^4l)
            print(io, """<code class="language-$language">""")
            print(io, chop(str))
            println(io, "</code>")
            l -= 1
            print(io, " "^4l)
            println(io, "</pre>")
        end
        if haskey(attributes, "cell")
            sandbox = get!(MODULES, String(attributes["cell"]), Module())
            captured = IOCapture.capture(rethrow=InterruptException) do
                include_string(sandbox, str)
            end
            if get(attributes, "output", "true") === "true" && captured.output !== ""
                print(io, " "^4l)
                println(io, """<pre data-type="programoutput">""")
                l += 1
                print(io, " "^4l)
                print(io, """<code>""")
                print(io, chop(captured.output))
                println(io, "</code>")
                l -= 1
                print(io, " "^4l)
                println(io, "</pre>")
            end
            if get(attributes, "result", "true") === "true" && captured.value !== nothing
                valio = IOBuffer()
                invokelatest(show, valio, "text/html", captured.value)
                for line in split(chop(String(take!(valio))), "\n")
                    print(io, " "^4l)
                    println(io, line)
                end
            end
        end
    end
    return l
end

function _html(io::IOBuffer, type::CommonMark.List, entering::Bool, str::String, attributes::Dict{String,Any}, level::Int64)
    l = level
    tag = if type.list_data.type == :ordered
        "ol"
    else
        "ul"
    end
    if entering
        print(io, " "^4l)
        println(io, """<$tag>""")
        l += 1
    else
        l -= 1
        print(io, " "^4l)
        println(io, "</$tag>")
    end
    return l
end

function _html(io::IOBuffer, type::CommonMark.Item, entering::Bool, str::String, attributes::Dict{String,Any}, level::Int64)
    l = level
    if entering
        print(io, " "^4l)
        println(io, """<li>""")
        l += 1
    else
        l -= 1
        print(io, " "^4l)
        println(io, "</li>")
    end
    return l
end

function _html(io::IOBuffer, type::CommonMark.Text, entering::Bool, str::String, attributes::Dict{String,Any}, level::Int)
    if entering
        print(io, str)
    end
    return level
end

end
