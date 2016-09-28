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
# query
include("column_indexable/query/interface.jl")
include("column_indexable/query/utils.jl")
include("column_indexable/query/generic.jl")
include("column_indexable/query/select.jl")
include("column_indexable/query/filter.jl")
include("column_indexable/query/groupby.jl")
include("column_indexable/query/summarize.jl")
# Grouped{T} query
include("column_indexable/grouped/query/generic.jl")
include("column_indexable/grouped/query/select.jl")
include("column_indexable/grouped/query/filter.jl")
include("column_indexable/grouped/query/summarize.jl")

end # module
