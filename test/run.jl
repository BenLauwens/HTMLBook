using HTMLBook

io = IOBuffer()
HTMLBook._tohtml(io, "first.md")
println(String(take!(io)))