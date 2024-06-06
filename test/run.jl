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
ast = p("""{#first}
# First chapter

This is a text with math: ``\\sqrt{1-x^2}``

## Subsection

```math
E=mc^2
```

!!! definition "This is it!"
    - First Element
    - Second Element
      - a sub element

```julia The best language
function say_hello(name::String)
    println("Hello, \$name!")
end
````
""")
CommonMark.ast_dump(ast)
println(CommonMark.html(ast))