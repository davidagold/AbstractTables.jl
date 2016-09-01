function jplyr._collect{T<:AbstractTable}(
    g_tbl::Grouped{T},
    g::jplyr.FilterNode
) #::Grouped
    f, arg_fields = jplyr.parts(g.helpers[1])
    new_src = rhs_filter(f, g_tbl.source, arg_fields)
    return grouped(new_src, g_tbl.groupbys, g_tbl.predicate_aliases)
end
