
# Schema-related
"""
"""
function fields end

"""
"""
function eltypes end

# eltypes(tbl)

function eltypes(tbl, fields...)
    idx = index(tbl)
    col_indices = [ idx[field] for field in fields ]
    return eltypes(tbl)[col_indices]
end

"""
"""
function nrow end

"""
"""
function index end

function index(tbl::AbstractTable)
    msg = @sprintf("Objects of type %s are not column-indexable", typeof(tbl))
    throw(ArgumentError(msg))
end
