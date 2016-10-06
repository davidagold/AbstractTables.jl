function StructuredQueries._collect{T<:AbstractTable}(
    g_tbl::Grouped{T}, q::SQ.FilterNode
)::Grouped
    new_src = SQ._collect(g_tbl.source, q)
    return grouped(new_src, g_tbl.groupbys, g_tbl.predicate_aliases)
end
