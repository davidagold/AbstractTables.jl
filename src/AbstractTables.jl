module AbstractTables

using Reexport
using Compat
@reexport using NullableArrays
@reexport using StructuredQueries
const SQ = StructuredQueries

export  AbstractTable,
        # fields,
        # index,
        # eltypes,
        # nrow,
        # ncol,
        # columns,
        # eachcol,
        # eachrow,
        Grouped

##############################################################################
##
## AbstractTable
##
##############################################################################

# API
include("abstracttable/typedef.jl")
include("abstracttable/traits.jl")
include("abstracttable/primitives.jl")
include("abstracttable/show.jl")
include("abstracttable/interface.jl")
include("abstracttable/collect.jl")

##############################################################################
##
## column-indexable
##
##############################################################################

# API
include("column_indexable/interface.jl")
include("column_indexable/iteration.jl")
include("column_indexable/show.jl")

# collect
include("column_indexable/collect/interface.jl")
include("column_indexable/collect/utils.jl")
include("column_indexable/collect/generic.jl")
include("column_indexable/collect/select.jl")
include("column_indexable/collect/filter.jl")
include("column_indexable/collect/groupby.jl")
include("column_indexable/collect/summarize.jl")

##############################################################################
##
## Grouped{T}
##
##############################################################################

# API
include("column_indexable/grouped/typedef.jl")
include("column_indexable/grouped/show.jl")

# collect
include("column_indexable/grouped/collect/generic.jl")
include("column_indexable/grouped/collect/select.jl")
include("column_indexable/grouped/collect/filter.jl")
include("column_indexable/grouped/collect/summarize.jl")

end # module
