# TODO: Include discussion of null storage patterns
"""
`AbstractTable` interface minimal requirements:

`columns(tbl)` => `Vector{Any}`
`fields(tbl)` => `Vector{Symbol}`
`index(tbl)` => `Dict{Symbol, Int}`
`setindex!(...)` exclusive means of adding new columns
`empty(tbl)` return an empty table of the same type as `tbl`
`copy(tbl)` return a copy of `tbl`

The contents of `columns(tbl)[i]` must be iterable. The orderings of
columns(tbl) and fields(tbl) must be consistent -- that is, fields(tbl)[i] must
be the field name of columns(tbl)[i]. The mapping in `index(tbl)` must respect
the ordering of columns and fields in `columns(tbl)` and `fields(tbl)`. This
ordering is assumed to be the canonical column ordering for `tbl`.

Depending on their internals, user-defined concrete `T<:AbstractTable` types
may also wish to implement the following methods (though they are guaranteed by
the `AbstractTable` interface):

`getindex(tbl, fld)` return the column corresponding to field `fld`
`eachrow(tbl)` return an iterator over rows realized as tuples

We do not guarantee that the number of rows can be directly obtained. However,
the AbstractTable interface provides traits that can be used to communicate
patterns of column data storage. If, for a user-defined type `T<:AbstractTable`,
the number of rows can be directly accessed via `nrow(tbl::T)`, the user may
set

    `AbstractTables.tblrowdim(::T) = AbstractTable.HasRowDim()`

to communicate this fact to code-path selection mechanisms in methods that deal
generally with `AbstractTable`s.
"""
abstract AbstractTable
