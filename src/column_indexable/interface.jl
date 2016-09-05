# Interface requirements:
# * columns
# * Base.getindex(tbl, field)
# * Base.setindex!(tbl, col, field)

"""
"""
function columns end

function columns(tbl::AbstractTable)
    msg = @sprintf("Objects of type %s are not column-indexable", typeof(tbl))
    throw(ArgumentError(msg))
end

# Base.copy
# Should this be a part of the column-indexable interface or the query
# sub-interface?
