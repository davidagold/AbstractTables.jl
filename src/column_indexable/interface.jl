# Interface requirements:
# * columns(tbl)::Vector{Any}
# * Base.getindex(tbl, field)
# * Base.setindex!(tbl, col, field)

# TODO: Include discussion of null storage patterns
"""
    columns(tbl::AbstractTable)::Vector{Any}

Produce a list of columns of `tbl` in canonical order.

This is a requisite method of the AbstractTable column-indexable interface. The
contents of `columns(tbl)[i]` must be iterable. The orderings of columns(tbl)
and fields(tbl) must be consistent -- that is, fields(tbl)[i] must be the field
name of columns(tbl)[i]. The mapping in `index(tbl)` must respect the ordering
of columns and fields in `columns(tbl)` and `fields(tbl)`. This ordering is
assumed to be the canonical column ordering for `tbl`.
"""
function columns end

function columns(tbl::AbstractTable)
    msg = @sprintf("Objects of type %s are not column-indexable", typeof(tbl))
    throw(ArgumentError(msg))
end
