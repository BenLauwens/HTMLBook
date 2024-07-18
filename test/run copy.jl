using NodeJS

const modules = normpath(joinpath(@__DIR__, "..", "deps", "node_modules"))
const tex2mml = normpath(joinpath(@__DIR__, "..", "js", "tex2mml.js"))
const highlight = normpath(joinpath(@__DIR__, "..", "js", "highlight.js"))
ENV["NODE_PATH"] = modules
text = "E = mc^2"
cmd = run(`$(nodejs_cmd()) $tex2mml --inline=true $text`)
mml = read(cmd, String)
println(mml)
text = """function sat_hello(name::String)
    println("Hello, \$(name)!")
end"""
cmd = run(`$(nodejs_cmd()) $highlight --language=julia $text`)
html = read(cmd, String)
println(html)

using CommonMark
p = Parser()
enable!(p, TypographyRule())
enable!(p, AttributeRule())
enable!(p, MathRule())
enable!(p, AdmonitionRule())
enable!(p, AutoIdentifierRule())
enable!(p, RawContentRule())
ast = p("""{#first}
# First chapter

This is a text `text` with math: ``\\sqrt{1-x^2}``

## Subsection

```math
E=mc^2
```

!!! definition "This is it!"
    - First Element
    - Second Element
      - a sub element

```julia; echo=false
function say_hello(name::String)
    return "Hello, \$name!"
end
```

This is raw HTML: `<img src="myimage.jpg">`{=html}.

```{=html}
<div class="article">
<p>Title</p>
</div>
```

![foo *bar*]

[foo *bar*]: train.jpg "train & tracks"
""")
CommonMark.ast_dump(ast)
println(CommonMark.html(ast))

using NativeSVG

dr = Drawing() do
    g(stroke_linecap="butt", stroke_miterlimit="4", stroke_width="3.0703125") do
        circle(cx="20", cy="20", r="16", stroke="#cb3c33", fill="#d5635c")
        circle(cx="40", cy="56", r="16", stroke="#389826", fill="#60ad51")
        circle(cx="60", cy="20", r="16", stroke="#9558b2", fill="#aa79c1")
    end
end

println(dr)

using HTMLBook