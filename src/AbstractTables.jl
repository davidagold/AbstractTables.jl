module AbstractTables

using Reexport
using Compat
@reexport using NullableArrays
@reexport using StructuredQueries
const SQ = StructuredQueries

export  AbstractTable,
        fields,
        eltypes,
        index,
        nrow,
        ncol,
        columns,
        eachcol,
        eachrow,
        Grouped

# AbstractTable
include("typedef.jl")
include("traits.jl")
include("interface.jl")
include("primitives.jl")
include("show.jl")

# column-indexable
## interface & primitives
include("column_indexable/interface.jl")
include("column_indexable/iteration.jl")
include("column_indexable/show.jl")
# Grouped{T}
include("column_indexable/grouped/typedef.jl")
include("column_indexable/grouped/show.jl")
# collect
include("column_indexable/collect/interface.jl")
include("column_indexable/collect/utils.jl")
include("column_indexable/collect/generic.jl")
include("column_indexable/collect/select.jl")
include("column_indexable/collect/filter.jl")
include("column_indexable/collect/groupby.jl")
include("column_indexable/collect/summarize.jl")
# Grouped{T} collect
include("column_indexable/grouped/collect/generic.jl")
include("column_indexable/grouped/collect/select.jl")
include("column_indexable/grouped/collect/filter.jl")
include("column_indexable/grouped/collect/summarize.jl")

end # module
