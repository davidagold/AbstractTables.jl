#= Required interface:

    * `AbstractTables.default(src)`
    * `Base.copy(src)`

Note that `default` must return a type that either (i) satisfies the
column-indexable interface or (ii) has its own collection machinery.
=#

"""
    default(tbl::AbstractTable)

Produce an empty table of an appropriate default type.
"""
function default end
