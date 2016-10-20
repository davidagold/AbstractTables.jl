Base.getindex(g_tbl::Grouped, field::Symbol) = getindex(g_tbl.source, field)
