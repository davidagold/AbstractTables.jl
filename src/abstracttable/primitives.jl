"""
Returns the number of dimensions of an AbstractTable.
"""
Base.ndims(::AbstractTable) = 2

"""
Returns the number of columns in an AbstractTable.
"""
ncol(tbl::AbstractTable) = length(fields(tbl))
