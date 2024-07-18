{data-type = chapter}
# First Chapter
This is a test. **Hello**, World!
## Math
This is a *formula*:
{#einstein}
```math
\begin{aligned}
    E&=&mc^2\\
    c^2&=&a^2+b^2
\end{aligned}
```
and this is an inline formula ``E=mc^2``, see [Einstein](#einstein).
{#figures}
## Figures
!!! proof
    This is a proof.
    - First
    and some comments
    - Secondly
    - Finally
    
    With a nice conclusion!

1. First
2. Second
```julia
function say_hello(name::String)
    println("Hello, ", name)
end
```
Test!

{cell=chap display=false}
```julia
using NativeSVG

function say_hello(name::String)
    println("Hello, ", name)
    Drawing() do
        g(stroke_linecap="butt", stroke_miterlimit="4", stroke_width="3.0703125") do
            circle(cx="20", cy="20", r="16", stroke="#cb3c33", fill="#d5635c")
            circle(cx="40", cy="56", r="16", stroke="#389826", fill="#60ad51")
            circle(cx="60", cy="20", r="16", stroke="#9558b2", fill="#aa79c1")
        end
    end
end

say_hello("Ben")
```

{cell=chap}
```julia
(1, 2, 3)
```

{cell=chap}
```julia
Drawing() do
    latex("E=mc^2", x="20", y="20", width="60", height="20")
end
```

!!! theorem "Archimedes"
    This is a theorem

And not a lemma.