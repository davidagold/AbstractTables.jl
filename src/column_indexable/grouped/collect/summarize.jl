SQ._collect(g_tbl::Grouped, q::SQ.SummarizeNode) =
    group_summarize(g_tbl, q)

"""
    new_groupby_column(src, groupby)::NullableVector

Return a `NullableVector` column
"""
new_groupby_column(src, groupby)::NullableVector =
    NullableVector{eltype(eltype(src[groupby]))}()

"""
    new_res_column(src, h)::NullableVector


"""
function new_res_column(src, h)::NullableVector
    res_field, f, g, arg_fields = SQ.parts(h)
    inner_eltypes = map(eltype, eltypes(src, arg_fields...))
    T = Core.Inference.return_type(f, (Tuple{inner_eltypes...}, ))
    U = Core.Inference.return_type(g, Tuple{Vector{T}})
    # TODO: slow path for non-leaf return types!
    return NullableVector{eltype(U)}()
end

"""
    init_columns(g_tbl::Grouped)

Return a
"""
function init_columns(src, groupbys, q)
    # Initialize columns containing groupby level data
    groupby_columns = Dict{Symbol, NullableVector}()
    for groupby in groupbys
        groupby_columns[groupby] =
            new_groupby_column(src, groupby)
    end
    # Initialize columns containing summarization results
    res_columns = Dict{Symbol, NullableVector}()
    for h in q.helpers
        res_columns[h.res_field] = new_res_column(src, h)
    end
    return groupby_columns, res_columns
end

function group_summarize(g_tbl, q)::Grouped
    src = g_tbl.source
    group_levels = g_tbl.group_levels
    groupbys = g_tbl.groupbys
    # Initialize columns for result table
    groupby_columns, res_columns = init_columns(src, groupbys, q)
    # group_level is the tuple of individual groupby levels
    for group_level in group_levels
        # enter indivudal groupby levels into columns
        # NOTE: assumes list of groupbys and product level have respecting orders
        for (groupby, groupby_level) in zip(groupbys, group_level)
            push!(groupby_columns[groupby], groupby_level)
        end
        # apply each summarization
        for h in q.helpers
            res_field = SQ.parts(h)[1]
            v = apply!(g_tbl, h, group_level)
            push!(res_columns[res_field], v)
        end
    end

    new_src = default(src)
    for groupby in groupbys
        new_src[groupby] = groupby_columns[groupby]
    end
    for helper in q.helpers
        res_field, f, g, arg_fields = SQ.parts(helper)
        new_src[res_field] = res_columns[res_field]
    end
    return groupby(new_src, groupbys, g_tbl.metadata[:predicates])
end

function apply!(g_tbl::Grouped, h::SQ.SummarizeHelper, key)
    res_field, f, g, arg_fields = SQ.parts(h)
    T, tpl_itr = _preprocess(f, arg_fields, g_tbl, key)
    # Allocate a temporary column.
    temp = Vector{T}()
    # Fill the new column in row-by-row, skipping nulls.
    _apply!(temp, h, tpl_itr)
    # Return the summarization function applied to the temporary.
    return g(temp)
end
