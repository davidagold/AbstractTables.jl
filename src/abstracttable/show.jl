function Base.show(io::IO, tbl::AbstractTable)
    if column_indexable(tbl)
        show_ci_tbl(io, tbl)
    else
        @printf(io, "A %s", typeof(tbl))
    end
end
