# Define a custom table type
type MyTable <: AbstractTable
    cols::Dict{Symbol, NullableVector}
end

# Convenience constructor

function (::Type{MyTable})(; kwargs...)
    cols = Dict{Symbol, NullableVector}()
    res = MyTable(cols)
    for (k, v) in kwargs
        res[k] = v
    end
    return res
end

# Satisfy AbstractTable interface
# Note: This assumes that the order of collect(keys(tbl.cols)) respects that of
# collect(values(tbl.cols))

AbstractTables.fields(tbl::MyTable) = collect(keys(tbl.cols))

AbstractTables.eltypes(tbl::MyTable) = map(eltype, collect(values(tbl.cols)))

AbstractTables.nrow(tbl::MyTable) =
    length(fields(tbl)) > 0 ? length(collect(values(tbl.cols))[1]) : 0

function AbstractTables.index(tbl::MyTable)
    idx = Dict{Symbol, Int}()
    for (j, field) in enumerate(fields(tbl))
        idx[field] = j
    end
    return idx
end

Base.copy(tbl::MyTable) = MyTable(copy(tbl.cols))

# Satisfy column-indexable interface

AbstractTables.columns(tbl::MyTable) = collect(values(tbl.cols))
Base.getindex(tbl::MyTable, field) = tbl.cols[field]
Base.setindex!(tbl::MyTable, col, field) = setindex!(tbl.cols, col, field)

AbstractTables.column_indexable(::MyTable) = true

# function Base.setindex!(tbl::MyTable, col::AbstractArray, field::Symbol)
#     nrows, ncols = nrow(tbl), ncol(tbl)
#     if (ncols > 0) & (length(col) != nrows)
#         msg = "All columns in a MyTable must be the same length"
#         throw(ArgumentError(msg))
#     end
#     j = get!(()->ncols+1, index(tbl), field)
#     cols = columns(tbl)
#     flds = fields(tbl)
#     if j <= ncols
#         cols[j] = convert(NullableArray, col)
#     else
#         push!(cols, convert(NullableArray, col))
#         push!(flds, field)
#     end
#     return col
# end

# Satisfy querying requirements

AbstractTables.default(::MyTable) = MyTable()

# For testing

Base.isequal(tbl1::MyTable, tbl2::MyTable) = isequal(tbl1.cols, tbl2.cols)
