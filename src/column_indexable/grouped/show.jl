function Base.show(
    io::IO,
    g_tbl::Grouped,
    # splitchunks::Bool = true,
    rowlabel::Symbol = Symbol("Row"),
    displaysummary::Bool = true
)::Void
    groupbys = g_tbl.groupbys
    nargs = length(groupbys)
    @printf(io, "Grouped %s\n", typeof(g_tbl).parameters[1])
    println(io, "Groupings by:")
    for groupby in groupbys
        print(io, " "^4)
        print_groupby(io, groupby, g_tbl.predicate_aliases)
    end
    println()
    print(io, "Source: "); show(io, g_tbl.source)
    return
end

function print_groupby(io, groupby, predicate_aliases)::Void
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
