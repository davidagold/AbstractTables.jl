function Base.show(
    io::IO, g_tbl::Grouped, # splitchunks::Bool = true,
    rowlabel::Symbol = Symbol("Row"), displaysummary::Bool = true
)::Void
    groupbys = g_tbl.groupbys
    # nargs = length(groupbys)
    predicates = g_tbl.metadata[:predicates]
    @printf(io, "Grouped %s\n", typeof(g_tbl).parameters[1])
    println(io, "Groupings by:")
    for groupby in groupbys
        print(io, " "^4)
        print_groupby(io, groupby, predicates)
    end
    println()
    print(io, "Source: "); show(io, g_tbl.source)
    return
end

function print_groupby(io, groupby, predicates)::Void
    if haskey(predicates, groupby)
        predicate = predicates[groupby]
        @printf(
            io, "%s (with alias :%s) \n", string(groupby), string(predicate)
        )
    else
        @printf(io, "%s \n", string(groupby))
    end
    return
end
