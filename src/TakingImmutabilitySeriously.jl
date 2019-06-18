module TakingImmutabilitySeriously

include("ImmutableArrays.jl")
using .ImmutableArrays

export freeze, thaw

include("cassette.jl")

end # module
