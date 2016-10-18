"""
    fields(tbl::AbstractTable)::Vector{Symbol}

Produce a list of column names of `tbl` in canonical order.
"""
function fields end

"""
    index(tbl::AbstractTable)::Dict{Symbol, Int}

Produce a mapping from fields to numerical indices, where the latter respect
the canonical order of columns of `tbl`.
"""
function index end

"""
    eltypes(tbl::AbstractTable[, fields...])::Vector{DataType}

Produce a list of eltypes of columns of `tbl` in canonical order. If `fields`
are specified, lists only eltypes of respective columns.
"""
function eltypes end

function eltypes(tbl::AbstractTable, fields...)
    idx = index(tbl)
    col_indices = [ idx[field] for field in fields ]
    return eltypes(tbl)[col_indices]
end

"""
    nrow(tbl::AbstractTable)::Int

Return the number of rows in `tbl` if known, -1 if unknown.
"""
function nrow end
