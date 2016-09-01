function Base.show(
    io::IO,
    g_tbl::Grouped,
    # splitchunks::Bool = true,
    rowlabel::Symbol = Symbol("Row"),
    displaysummary::Bool = true
)::Void
    groupbys = g_tbl.groupbys
    nargs = length(groupbys)
    println(io, typeof(g_tbl))
    println(io, "Groupings by:")
    for groupby in groupbys
        print(io, " "^4)
        print_groupby(io, groupby, g_tbl.predicate_aliases)
    end
    println()
    return show(io, g_tbl.source, :Row, false)
end

function print_groupby(io, groupby::Union{Symbol, Expr}, predicate_aliases)
    if isa(groupby, Symbol)
        @printf(io, "%s \n", string(groupby))
    else
        groupby_pred = predicate_aliases[groupby]
        @printf(
            io,
            "%s (with alias :%s) \n",
            string(groupby),
            string(groupby_pred)
        )
    end
    return
end
