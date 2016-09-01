module AbstractTables

using Reexport
using Compat
@reexport using NullableArrays
@reexport using jplyr

export  AbstractTable,
        fields,
        index,
        nrow,
        ncol,
        columns,
        eachcol,
        eachrow,
        Grouped

include("typedef.jl")
include("traits.jl")
include("interface.jl")
include("primitives.jl")
include("show.jl")

include("column_indexable/interface.jl")
include("column_indexable/iteration.jl")

include("column_indexable/grouped/typedef.jl")
include("column_indexable/grouped/show.jl")

include("column_indexable/query/interface.jl")
include("column_indexable/query/utils.jl")
include("column_indexable/query/generic.jl")
include("column_indexable/query/select.jl")
include("column_indexable/query/filter.jl")
include("column_indexable/query/groupby.jl")
include("column_indexable/query/summarize.jl")

include("column_indexable/grouped/query/generic.jl")
include("column_indexable/grouped/query/select.jl")
include("column_indexable/grouped/query/filter.jl")
include("column_indexable/grouped/query/summarize.jl")

end # module
