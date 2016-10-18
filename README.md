# AbstractTables

[![Build Status](https://travis-ci.org/davidagold/AbstractTables.jl.svg?branch=master)](https://travis-ci.org/davidagold/AbstractTables.jl)
<!--[![Coverage Status](https://coveralls.io/repos/davidagold/AbstractTables.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/davidagold/AbstractTables.jl?branch=master)-->
[![codecov.io](http://codecov.io/github/davidagold/AbstractTables.jl/coverage.svg?branch=master)](http://codecov.io/github/davidagold/AbstractTables.jl?branch=master)

This package demonstrates a series of abstract interfaces for tabular data structures in Julia. Its objective is to support modularity and extensibility in the development of data management facilities. In particular, we demonstrate support for querying facilities that are generic over the class of so-called *column-indexable* tabular data structures. The latter are in-memory Julia objects that satisfy the column-indexable interface. The querying interface itself is provided by [(code-name) StructuredQueries](https://github.com/davidagold/StructuredQueries.jl) and extended by the present package.

## Interfaces

We take an *interface* that may be satisfied by a Julia data type `T` to include:

1. A collection of *requisite methods* that must be defined for `T`;
2. A collection of *provided methods* that depend on the existence of the above requisite methods;
3. (Possibly) the requirement that `T` be defined as a subtype of some abstract type specific to the interface.

We say that an interface I *includes* an interface J if all of the requisite methods (and subtypings) for J are also requisite for I.

The present package defines three interfaces:

1. A basic `AbstractTable` interface
2. A *column-indexable* interface
3. A query interface for column-indexable `AbstractTable`s.

### `AbstractTable` interface

The basic `AbstractTable` interface for a tabular data type `T <: AbstractTable` consists of minimalist funtionality concerning only the "schema" of tables of type `T <: AbstractTable`; it neither requires nor exposes any methods that depend on specific storage layouts of the data contained in the table.

Requisite methods:
* `AbstractTables.fields(tbl::T)`
* `AbstractTables.eltypes(tbl::T)`
* `AbstractTables.nrow(tbl::T)`
* `AbstractTables.index(tbl::T)`

Provided methods:
* `AbstractTables.eltypes(tbl::T, fields...)`
* `Base.ndims(tbl::T)`
* `AbstractTables.ncol(tbl::T)`
* `Base.show(tbl::T)`

### Column-indexable interface

The column-indexable interface is designed to suit tabular data types `T <: AbstractTable` for which entire columns can be retrieved as or set from in-memory iterable Julia vector-like objects (If you have suggestions as to how the foregoing chain of adjectives ought to be arranged, please file a PR).

Requisite methods:
* `AbstractTables.columns(tbl::T)`
* `Base.getindex(tbl::T, field)`
* `Base.setindex!(tbl::T, col, field)`

Provided methods:
* `AbstractTables.eachcol(tbl::T)`
* `AbstractTables.eachrow(tbl::T)`
* `AbstractTables.eachrow(tbl::T, fields...)`

### Query interface (column-indexable specific)

The query interface for column-indexable types `T <: AbstractTable` leverages the ability to retrieve and set columns represented as in-memory Julia vectors in its extension of the `StructuredQueries` `Query` framework.

Required methods:
* `default(tbl::T)`
* `Base.copy(tbl::T)`

Provided methods:
* `collect(Query{T})`
