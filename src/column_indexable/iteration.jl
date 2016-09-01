# TODO: Implement the following as a performant (when the number of columns is
# large) alternative to a zipped iterator
# """
# """
# immutable TableRowIterator{T}
#     cols::T
# end
#
# Base.start(itr::TableRowIterator) = 1
# @generated function Base.next{T}(itr::TableRowIterator{T}, st)
#     ncols = length(T.parameters)
#     tuple_ex = Expr(:tuple)
#     for j in 1:ncols
#         push!(tuple_ex.args, :( itr.cols[$j][st] ))
#     end
#     return quote
#         return ($tuple_ex, st+1)
#     end
# end
# Base.done(itr::TableRowIterator, st) =
#     length(itr.cols) > 0 ? done(itr.cols[1], st) : true
#
# AbstractTables.eachrow(tbl::Table) = TableRowIterator(tuple(columns(tbl)...))
# function AbstractTables.eachrow(tbl::Table, flds...)
#     cols = [ tbl[fld] for fld in flds ]
#     TableRowIterator(tuple(cols...))
# end

"""
"Enumerate" the columns of an AbstractTable by field (column name).

Arguments:

* tbl::AbstractTable

Returns:

* cols::Base.Zip2{Array{Symbol,1},Array{Any,1}}: An iterator over
`(field, column)` pairs from `tbl`.
"""
eachcol(tbl::AbstractTable) = zip(fields(tbl), columns(tbl))

"""
    `eachrow(tbl, [flds...])`

Return an iterator over the rows (materialized as `Tuple`s) of `tbl`. If `flds`
are specified, the tuples returned by the row iterator will contain data from
only the respective columns.
"""
eachrow(tbl::AbstractTable) = zip(columns(tbl)...)
function eachrow(tbl::AbstractTable, fields...)
    cols = [ tbl[field] for field in fields ]
    return zip(cols...)
end
