#= Required interface:

    * `default(src)`
    * `eachrow(src [, fields...])`
    * `eltypes(src [, fields...])`

Note that `default` must return a type that satisfies the column indexable
interface
=#

"""
    default(tbl::AbstractTable)

Produce an empty table of an appropriate default type.
"""
function default end

# """
#     empty(tbl::AbstractTable)
#
# Produce an empty table of the same type as `tbl`.
# """
# function empty end
