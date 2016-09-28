function SQ._collect(tbl, g::SQ.GroupbyNode)
    src = copy(tbl)
    predicate_aliases = Dict{Expr, Symbol}()
    pre_groupby!(src, g, predicate_aliases)
    return groupby(src, g.args, predicate_aliases)
end

"""
"""
function pre_groupby!(src, q, predicate_aliases)
    i = 1 # count number of predicate aliases
    for (h, arg) in zip(q.helpers, q.args)
        is_predicate, f, arg_fields = SQ.parts(h)
        if is_predicate
            predicate_alias = Symbol("pred_$i")
            predicate_aliases[arg] = predicate_alias
            # include the result of applying the predicate as a new column
            apply!(src, SQ.SelectHelper(predicate_alias, f, arg_fields), src)
            i += 1
        end
    end
end

"""
"""
function groupby{T<:AbstractTable}(
    src::T, groupbys, predicate_aliases
)::Grouped{T}
    # obtain the field names of the groupbys (either the names of the selected
    # columns or the predicate aliases given to groupby predicates)
    # TODO: store this information in the `groupbys` field of the result
    groupby_fields = map(x->isa(x, Symbol) ? x : predicate_aliases[x], groupbys)
    group_indices = build_group_indices(src, groupby_fields)
    group_levels = build_group_levels(group_indices, length(groupby_fields))
    return Grouped(
        src,
        group_indices,
        GroupLevels(group_levels),
        groupbys,
        predicate_aliases
    )
end

function build_group_levels(group_indices, ngroupbys)
    joint_group_levels = collect(keys(group_indices))
    group_levels = Vector{Vector}(ngroupbys)
    for j in 1:ngroupbys
        group_levels[j] = [ level[j] for level in joint_group_levels ]
    end
    map!(unique, group_levels)
    return group_levels
end

function build_group_indices(tbl, groupbys)
    row_itr = eachrow(tbl, groupbys...)
    # TODO: type this more strongly
    group_indices = Dict{Any, Vector{Int}}()
    grow_indices!(group_indices, row_itr)
    return group_indices
end

@noinline function grow_indices!(group_indices, row_itr)
    for (i, row) in enumerate(row_itr)
        group_level = row
        if haskey(group_indices, group_level)
            push!(group_indices[group_level], i)
        else
            group_indices[group_level] = [i]
        end
    end
    return group_indices
end
