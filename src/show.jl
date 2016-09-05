function Base.show(io::IO, tbl::AbstractTable)
    if column_indexable(tbl)
        _ci_show(io, tbl)
    else
        @printf(io, "A %s", typof(tbl))
    end
end
