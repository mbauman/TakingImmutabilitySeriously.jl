using Cassette, ReplMaker

Cassette.@context Immutabilitizer

maybefreeze(x) = x
maybefreeze(A::Array) = freeze(A)

# zeros was considered but removed after considering usage in dict's rehash!
# also removed ones, fill as well due to the above
for f in (rand, randn, *, +, -, /, Broadcast.materialize)
    @eval Cassette.overdub(::Immutabilitizer, ::typeof($f), args...) = maybefreeze($f(args...))
end

# Treat .= as an optional mutation
Cassette.overdub(::Immutabilitizer, ::typeof(Broadcast.materialize!), dest::ImmutableArray, x) = freeze(Broadcast.materialize!(thaw(dest), x))

# Create a REPL mode
function parse_to_expr(s)
    p = Meta.parse(s)
    isa(p, Expr) && p.head in (:using, :import) && return p
    quote $Cassette.@overdub($(Immutabilitizer()), $p) end
end
initrepl(parse_to_expr,
                prompt_text="Immutable> ",
                prompt_color = :blue,
                start_key=')',
                mode_name="Immutable_mode")


# Interesting examples:
# Dict rehash! fails because it uses zeros as a calloc
# Plots.plot(1:10, rand(10)) - fails with a Cassette bug
# Flux.train!()
# - fails because TrackedArray requires ::Arrays
# - Moved to the sf/Zygote branch, and then...
# - fails because it tries to materialize! into a reshaped immutable array. Fixed by making reshape a copy (that's potentially elided)
# - uses both zeros and randn to initialize its weights — making an asymmetry between immutable and not between W (from rand) and b (from zeros)
# svd(rand(10,10)) \ rand(10) -- returns an immutable array
#
# 
# A common idiom:
# function f(A)
#     result = similar(A)
#     for i in eachindex(result)
#         result[i] = op(A[i])
#     end
#     return freeze(result)
# end