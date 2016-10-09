"""
`AbstractTable`

An abstract tabular data type.

The `AbstractTable` interface requisite methods can be found in
`src/interface.jl`.

The column-indexable interface (which assumes satisfaction of the
`AbstractTable` interface) requisite methods can be found in
`src/column-indexable/interface.jl`.

The query interface for column-indexable `T<:AbstractTable` requisite methods
can be found in `src/column-indexable/query/interface.jl`.
"""
abstract AbstractTable
