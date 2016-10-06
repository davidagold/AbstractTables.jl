function SQ._collect{T<:AbstractTable}(
    g_tbl::Grouped{T}, q::SQ.SelectNode
)::Grouped
    src = g_tbl.source
    new_src = default(src)
    groupby_fields = map(
        x -> isa(x, Symbol) ? x : g_tbl.predicate_aliases[x],
        g_tbl.groupbys
    )
    # Copy all columns involved in the original grouping
    for groupby_field in groupby_fields
        new_src[groupby_field] = src[groupby_field]
    end
    # Apply the select query
    for h in q.helpers
        apply!(new_src, h, src)
    end
    return Grouped(
        new_src,
        g_tbl.group_indices,
        g_tbl.group_levels,
        g_tbl.groupbys,
        g_tbl.predicate_aliases
    )
end
