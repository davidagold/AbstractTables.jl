function jplyr._collect{T<:AbstractTable}(g_tbl::Grouped{T}, g::jplyr.SelectNode)
    src = g_tbl.source
    new_src = empty(src)
    groupby_fields = map(
        x -> isa(x, Symbol) ? x : g_tbl.predicate_aliases[x],
        g_tbl.groupbys
    )

    # Copy all columns involved in the original grouping
    for groupby_field in groupby_fields
        new_src[groupby_field] = src[groupby_field]
    end

    # Apply the select query
    for helper in g.helpers
        apply!(new_src, helper, src)
    end

    return Grouped(
        new_src,
        g_tbl.group_indices,
        g_tbl.group_levels,
        g_tbl.groupbys,
        g_tbl.predicate_aliases
    )
end
